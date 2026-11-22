"""Stage 2 of docs/v5/development/pipeline-overhaul.md: dish types, target ratios, budget and metrics.

Read-only over the queue, checkpoints, exclusions and dataset; no network.

    python3 src/collection.py metrics            # print the metrics report
    python3 src/collection.py metrics --write    # also save reports/metrics.md
    python3 src/collection.py plan --budget 40   # how to spend the next 40 Gemini calls (70/30)
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

from recipe_rules import DATA_DIR, ROOT, RULES_DIR, Catalog, _norm
from validator import DISH_TYPES
from video_queue import read_queue

STATE_DIR = ROOT / "state"
REPORT_FILE = ROOT / "reports" / "metrics.md"
EXPLOIT_SHARE = 0.7
MIN_SAMPLE = 10  # below this a channel's yield is not trusted (doc: 수집 예산 배분)
_VIDEO_ID = re.compile(r"(?:shorts/|youtu\.be/|[?&]v=)([A-Za-z0-9_-]{11})")


# ---------- dish types ----------

def clean_title(title: str) -> str:
    """Drop hashtags, [bracketed] notes and emoji so patterns anchored at a word end still match."""
    text = re.sub(r"#\S+|\[[^\]]*\]", " ", title or "")
    text = re.sub(r"[^\w\s!?.,~·&+()-]", " ", text)
    return re.sub(r"\s+", " ", text).strip()


@dataclass(frozen=True)
class DishType:
    code: str
    label: str
    target: float  # percent
    is_cap: bool
    patterns: tuple[re.Pattern, ...]


@dataclass(frozen=True)
class Taxonomy:
    types: tuple[DishType, ...]
    overrides: dict[str, str]
    dessert_words: tuple[str, ...] = ()

    @classmethod
    def load(cls, rules_dir: Path = RULES_DIR) -> "Taxonomy":
        data = json.loads((rules_dir / "dish-types.json").read_text(encoding="utf-8"))
        types = tuple(DishType(t["code"], t["label"], float(t["targetPercent"]), bool(t.get("isCap")),
                               tuple(re.compile(p) for p in t["patterns"])) for t in data["types"])
        codes = [t.code for t in types]
        if sorted(codes) != sorted(DISH_TYPES):
            raise ValueError(f"dish-types.json codes {codes} must match validator.DISH_TYPES")
        overrides = data.get("overrides", {}).get("videos", {})
        unknown = {v for v in overrides.values() if v not in codes}
        if unknown:
            raise ValueError(f"dish-types.json overrides use unknown codes {unknown}")
        return cls(types, dict(overrides), tuple(data.get("dessertWords", {}).get("words", [])))

    def label(self, code: str) -> str:
        return next((t.label for t in self.types if t.code == code), code)

    def classify_name(self, name: str) -> str:
        text = clean_title(name)
        if any(word in text for word in self.dessert_words):
            return "OTHER"
        for dish_type in self.types:
            if any(p.search(text) for p in dish_type.patterns):
                return dish_type.code
        return "OTHER"

    def other_types(self, name: str) -> tuple[str, set[str]]:
        """(main type, types matched outside the word that gave the main type).

        Lets discover keep "라면보다 쉬운 계란국" (계란국 is still collected) while still dropping
        "두부조림덮밥" (조림 is part of the rice-bowl word itself).
        """
        text = clean_title(name)
        main = self.classify_name(name)
        if main == "OTHER":
            return main, set()
        dish = next(t for t in self.types if t.code == main)
        match = next(m for m in (p.search(text) for p in dish.patterns) if m)
        start = text.rfind(" ", 0, match.start()) + 1
        end = text.find(" ", match.end())
        rest = text[:start] + " " + (text[end:] if end != -1 else "")
        return main, {t.code for t in self.types if t.code != "OTHER" and any(p.search(rest) for p in t.patterns)}

    def classify(self, video_id: str, name: str | None, gemini_type: str | None) -> tuple[str, str]:
        """(code, how): override > Gemini dishType (extraction v2) > name rules."""
        if video_id in self.overrides:
            return self.overrides[video_id], "override"
        if gemini_type in DISH_TYPES:
            return gemini_type, "gemini"
        return self.classify_name(name or ""), "name"


# ---------- one row per queued video ----------

STAGES = ("queued", "short_ok", "extracted", "in_dataset", "published")
# Old checkpoints reviewed by a person or agent before the V3 extraction existed (status DRAFT /
# REVIEW_PENDING with no extraction result). They are left out of the funnel and counted apart.
LEGACY = "legacy_review"
STAGE_LABELS = {"queued": "큐", "short_ok": "쇼츠·임베드 통과", "extracted": "추출", "in_dataset": "반영", "published": "공개"}


@dataclass
class Row:
    video_id: str
    channel: str
    channel_id: str | None
    source: str
    query: str | None
    added_at: str | None
    dish_type: str
    classified_by: str
    stage: str  # furthest stage reached
    excluded: str | None  # exclusion category


def _json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


def load_rows(taxonomy: Taxonomy, root: Path = ROOT, data_dir: Path = DATA_DIR) -> list[Row]:
    exclusions = _json(root / "rules" / "exclusions.json").get("videos", {})
    recipes = {}
    for path in sorted((data_dir / "recipes").glob("*.json")):
        recipe = _json(path)
        match = _VIDEO_ID.search(recipe.get("shortsReference", ""))
        if match:
            recipes[match.group(1)] = recipe
    rows = []
    for entry in read_queue(root / "input" / "queue.jsonl"):
        video_id = entry["videoId"]
        state = _json(root / "state" / f"{video_id}.json")
        result = (state.get("extraction") or {}).get("result") or {}
        meta = state.get("sourceMetadata") or {}
        recipe = recipes.get(video_id)
        category = (exclusions.get(video_id) or {}).get("category")
        status = state.get("status")
        not_short = category in ("NOT_SHORT", "NOT_EMBEDDABLE") or status == "SKIPPED_NOT_SHORT"
        if not_short:
            stage = "queued"  # even if it was extracted before the check existed
        elif recipe and recipe.get("status") == "PUBLISHED":
            stage = "published"
        elif recipe:
            stage = "in_dataset"
        elif status == "EXTRACTION_READY":
            stage = "extracted"
        elif status in ("DRAFT", "REVIEW_PENDING") and not result:
            stage = LEGACY
        elif status in (None, "PENDING", "CLAIMED", "EXTRACTION_RUNNING", "RUNNING"):
            stage = "queued"  # not processed yet
        else:
            stage = "short_ok"  # processed, extraction failed or waiting for retry
        name = (recipe or {}).get("name") or result.get("recipeName") or result.get("title") or entry.get("title")
        code, how = taxonomy.classify(video_id, name, result.get("dishType"))
        channel = meta.get("sourceChannelName") or (recipe or {}).get("sourceChannelName") or entry.get("channel") or "(모름)"
        channel_id = meta.get("sourceChannelId") or (recipe or {}).get("sourceChannelId")
        rows.append(Row(video_id, channel.strip(" ."), channel_id, entry.get("source", "manual"), entry.get("query"), entry.get("addedAt"),
                        code, how, stage, category))
    return rows


def reached(row: Row, stage: str) -> bool:
    return row.stage != LEGACY and STAGES.index(row.stage) >= STAGES.index(stage)


# ---------- distribution ----------

def distribution(rows: list[Row], taxonomy: Taxonomy) -> list[dict]:
    published = [r for r in rows if r.stage == "published"]
    counts = Counter(r.dish_type for r in published)
    total = len(published) or 1
    result = []
    for t in taxonomy.types:
        share = 100 * counts[t.code] / total
        over = share > t.target if t.target or t.code != "OTHER" else False
        result.append({"code": t.code, "label": t.label, "count": counts[t.code], "share": share,
                       "target": t.target, "isCap": t.is_cap, "over": over, "gap": t.target - share})
    return result


def over_target(rows: list[Row], taxonomy: Taxonomy) -> set[str]:
    """Types whose published share is above target: new collection of these stops (doc)."""
    return {d["code"] for d in distribution(rows, taxonomy) if d["over"] and d["code"] != "OTHER"}


# ---------- yields ----------

@dataclass
class Yield:
    key: str
    extracted: int
    published: int
    prior: float = 0.35  # overall extracted -> published rate; set by yields()

    @property
    def rate(self) -> float:
        return self.published / self.extracted if self.extracted else 0.0

    @property
    def expected(self) -> float:
        """Shrunk toward the overall rate with the weight of MIN_SAMPLE videos, so 2 of 2 does not beat 30 of 40."""
        return (self.published + self.prior * MIN_SAMPLE) / (self.extracted + MIN_SAMPLE)

    @property
    def interval(self) -> tuple[float, float]:
        """Rough 90% Wilson interval, shown so a 2/2 channel does not read as a sure thing."""
        n = self.extracted
        if not n:
            return (0.0, 1.0)
        p, z = self.rate, 1.645
        centre = (p + z * z / (2 * n)) / (1 + z * z / n)
        spread = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / (1 + z * z / n)
        return (max(0.0, centre - spread), min(1.0, centre + spread))


def channel_key(row: Row) -> str | None:
    """Channels are counted by YouTube channel ID when known; names change and vary in punctuation."""
    if row.channel_id:
        return row.channel_id
    return None if row.channel == "(모름)" else "name:" + row.channel


def channel_names(rows: list[Row]) -> dict[str, str]:
    names: dict[str, Counter] = defaultdict(Counter)
    for row in rows:
        key = channel_key(row)
        if key:
            names[key][row.channel] += 1
    return {key: counter.most_common(1)[0][0] for key, counter in names.items()}


def yields(rows: list[Row], key) -> list[Yield]:
    extracted, published = Counter(), Counter()
    for row in rows:
        if reached(row, "extracted"):
            k = key(row)
            if k is None:
                continue
            extracted[k] += 1
            published[k] += row.stage == "published"
    prior = (sum(published.values()) / sum(extracted.values())) if extracted else 0.35
    return sorted((Yield(k, extracted[k], published[k], prior) for k in extracted), key=lambda y: (-y.expected, y.key))


# ---------- user-perspective diversity ----------

def load_inventories(catalog: Catalog, rules_dir: Path = RULES_DIR) -> dict[str, set[str]]:
    data = json.loads((rules_dir / "sample-inventories.json").read_text(encoding="utf-8"))
    result = {}
    for name, items in data["inventories"].items():
        keys = set()
        for item in data.get("pantry", []) + items:
            found = catalog.variant_by_name.get(_norm(item))
            if not found:
                raise ValueError(f"sample-inventories.json: '{item}' is not a catalog name")
            keys.add(found[0])
        result[name] = keys
    return result


def makeable(recipe: dict, owned: set[str]) -> bool:
    """Every requirement has an option the inventory covers (exact, accepted, allowed or substitute)."""
    by_key = {i["key"]: i for i in recipe["ingredients"]}

    def covers(key: str, allowed=()) -> bool:
        item = by_key.get(key) or {}
        kinds = {item.get("variant")} | set(item.get("acceptedOwnedVariants") or []) | set(allowed)
        return bool(kinds & owned)

    for requirement in recipe["requirements"]:
        if not any(covers(o["ingredient"], o.get("allowedVariants") or []) or
                   any(covers(s) for s in o.get("substitutes") or []) for o in requirement["options"]):
            return False
    return True


def diversity(taxonomy: Taxonomy, catalog: Catalog, rows: list[Row], data_dir: Path = DATA_DIR) -> list[dict]:
    types = {r.video_id: r.dish_type for r in rows}
    recipes = []
    for path in sorted((data_dir / "recipes").glob("*.json")):
        recipe = _json(path)
        match = _VIDEO_ID.search(recipe.get("shortsReference", ""))
        if recipe.get("status") == "PUBLISHED" and match:
            code = types.get(match.group(1)) or taxonomy.classify_name(recipe["name"])
            recipes.append((recipe, code))
    result = []
    for name, owned in load_inventories(catalog).items():
        hits = [(r, code) for r, code in recipes if makeable(r, owned)]
        result.append({"inventory": name, "recipes": len(hits), "types": Counter(code for _, code in hits)})
    return result


# ---------- collection plan ----------

def plan(rows: list[Row], taxonomy: Taxonomy, budget: int, queries: dict[str, list[str]]) -> dict:
    """Split `budget` Gemini calls: 70% exploit proven channels, 30% explore under-target types and new channels.

    Yield is a reference signal only: channels with fewer than MIN_SAMPLE extractions never count as
    proven, and every exploit channel is capped so one popular channel cannot take the whole budget.
    """
    exploit_calls = round(budget * EXPLOIT_SHARE)
    explore_calls = budget - exploit_calls
    blocked = over_target(rows, taxonomy)
    names = channel_names(rows)
    # Judge channels only on dish types we still collect: a channel that is good at rice bowls must not
    # get budget once rice bowls are blocked (the feedback loop the doc warns about).
    channel_yields = yields([r for r in rows if r.dish_type not in blocked], channel_key)
    proven = [y for y in channel_yields if y.extracted >= MIN_SAMPLE and y.expected > 0]
    exploit, total_weight = [], sum(y.expected for y in proven) or 1
    cap = max(1, math.ceil(exploit_calls * 0.35))
    remaining = exploit_calls
    for y in proven:
        calls = min(cap, max(1, round(exploit_calls * y.expected / total_weight)), remaining)
        if calls <= 0:
            break
        exploit.append({"channel": names.get(y.key, y.key), "channelId": None if y.key.startswith("name:") else y.key,
                        "calls": calls, "expected": y.expected, "sample": y.extracted})
        remaining -= calls
    explore_calls += remaining  # anything not used by proven channels goes to exploring

    gaps = [d for d in distribution(rows, taxonomy) if d["gap"] > 0 and d["code"] != "OTHER"]
    gap_total = sum(d["gap"] for d in gaps) or 1
    type_calls = math.ceil(explore_calls * 2 / 3) if gaps else 0
    explore_types = []
    left = type_calls
    used = Counter(r.query for r in rows if r.query)
    for d in sorted(gaps, key=lambda d: -d["gap"]):
        calls = min(left, max(1, round(type_calls * d["gap"] / gap_total)))
        if calls <= 0:
            break
        # least-used queries first, so repeated runs do not search the same words
        ordered_queries = sorted(queries.get(d["code"], []), key=lambda q: (used[q], queries[d["code"]].index(q)))
        explore_types.append({"code": d["code"], "label": d["label"], "calls": calls, "queries": ordered_queries})
        left -= calls
    unproven = sorted((Yield(names.get(y.key, y.key), y.extracted, y.published, y.prior)
                       for y in channel_yields if y.extracted < MIN_SAMPLE), key=lambda y: (y.extracted, y.key))
    return {"budget": budget, "exploit": exploit, "exploreTypes": explore_types,
            "exploreNewChannels": explore_calls - (type_calls - left), "unprovenChannels": unproven[:10],
            "blockedTypes": sorted(blocked)}


_MAPPING_REASONS = ("카탈로그에 없는", "카탈로그의", "여러 종류를 묶은", "대체", "다른 재료 표기")


def blocked_reasons(rows: list[Row], root: Path = ROOT) -> dict[str, Counter]:
    """Why extracted videos did not become published recipes, per dish type (uses the apply tool's rules).

    "master" means unmapped ingredients are the only thing in the way; anything else needing a person
    counts as "review".
    """
    from apply import REVIEW, SKIP, WAIT_MASTER, build, deleted_video_ids, load_dataset
    from recipe_rules import load_rules, name_key
    rules, catalog = load_rules(), Catalog.load()
    name_counts = Counter(name_key(recipe["name"]) for _, recipe in load_dataset().values())
    deleted = deleted_video_ids()
    result: dict[str, Counter] = defaultdict(Counter)
    for row in rows:
        if row.stage in ("in_dataset", "extracted") and row.excluded:
            result[row.dish_type]["policy"] += 1
        elif row.stage == "in_dataset":
            result[row.dish_type]["master"] += 1  # drafts in the dataset wait for catalog ingredients
        elif row.stage == "extracted":
            state = _json(root / "state" / f"{row.video_id}.json")
            if not (state.get("extraction") or {}).get("result"):
                result[row.dish_type]["other"] += 1
                continue
            outcome = build(row.video_id, state, rules, catalog, {}, name_counts, deleted)
            kind = {WAIT_MASTER: "master", REVIEW: "review", SKIP: "policy"}.get(outcome.outcome, "other")
            if outcome.outcome == REVIEW and outcome.unresolved and all(
                    any(word in reason for word in _MAPPING_REASONS) for reason in outcome.reasons):
                kind = "master"
            result[row.dish_type][kind] += 1
    return result


# ---------- report ----------

def _pct(value: float) -> str:
    return f"{value:.0f}%"


def render_metrics(rows: list[Row], taxonomy: Taxonomy, catalog: Catalog) -> str:
    lines = ["# 수집 지표", ""]
    legacy = sum(r.stage == LEGACY for r in rows)
    funnel = [(s, sum(reached(r, s) for r in rows)) for s in STAGES]
    lines += ["## 단계별 수율", "", "| 단계 | 영상 | 앞 단계 대비 |", "| --- | --- | --- |"]
    previous = None
    for stage, count in funnel:
        ratio = _pct(100 * count / previous) if previous else "-"
        lines.append(f"| {STAGE_LABELS[stage]} | {count} | {ratio} |")
        previous = count or None
    lines += ["", f"V3 추출 전에 사람이 검토해 정리한 옛 영상 {legacy}개는 단계 수율에서 뺐다.", ""]

    lines += ["## 요리 종류: 공개 레시피 비율과 목표", "", "| 종류 | 공개 | 비율 | 목표 | 상태 |", "| --- | --- | --- | --- | --- |"]
    for d in distribution(rows, taxonomy):
        if d["code"] == "OTHER" and not d["count"]:
            continue
        target = f"{'≤' if d['isCap'] else ''}{d['target']:.0f}%"
        status = "목표 초과: 신규 수집 멈춤" if d["over"] and d["code"] != "OTHER" else (f"{d['gap']:.0f}%p 부족" if d["gap"] > 0 else "")
        lines.append(f"| {d['label']} | {d['count']} | {_pct(d['share'])} | {target} | {status} |")
    how = Counter(r.classified_by for r in rows if r.stage == "published")
    lines += ["", f"분류 근거: Gemini {how['gemini']}, 이름 규칙 {how['name']}, 수동 지정 {how['override']}.", ""]

    lines += ["## 종류별 수율 (추출 → 공개)", "", "| 종류 | 추출 | 공개 | 수율 | 90% 범위 |", "| --- | --- | --- | --- | --- |"]
    for y in sorted(yields(rows, lambda r: r.dish_type), key=lambda y: (-y.extracted, y.key)):
        low, high = y.interval
        lines.append(f"| {taxonomy.label(y.key)} | {y.extracted} | {y.published} | {_pct(100 * y.rate)} | {_pct(100 * low)}–{_pct(100 * high)} |")
    lines.append("")

    lines += ["## 종류별로 공개되지 못한 이유", "",
              "국물 요리처럼 수율이 낮은 종류가 영상 탓인지 재료 마스터 탓인지 구분한다. 추출됐지만 공개되지 않은 영상만 센다.", "",
              "| 종류 | 재료 매핑만 남음 | 사람 확인 필요 | 정책·제외 | 기타 |", "| --- | --- | --- | --- | --- |"]
    reasons = blocked_reasons(rows)
    for code, counter in sorted(reasons.items(), key=lambda kv: -sum(kv[1].values())):
        lines.append(f"| {taxonomy.label(code)} | {counter['master']} | {counter['review']} | {counter['policy']} | {counter['other']} |")
    lines.append("")

    lines += ["## 채널별 수율 (추출 → 공개)", "", f"추출 {MIN_SAMPLE}건 미만인 채널은 수율을 믿지 않고 탐험으로 본다.", "",
              "| 채널 | 추출 | 공개 | 수율 | 90% 범위 | 표본 |", "| --- | --- | --- | --- | --- | --- |"]
    names = channel_names(rows)
    for y in sorted(yields(rows, channel_key), key=lambda y: (-y.extracted, -y.published, y.key))[:30]:
        low, high = y.interval
        lines.append(f"| {names.get(y.key, y.key)} | {y.extracted} | {y.published} | {_pct(100 * y.rate)} | {_pct(100 * low)}–{_pct(100 * high)} | "
                     f"{'충분' if y.extracted >= MIN_SAMPLE else '부족'} |")
    lines.append("")

    query_yields = yields(rows, lambda r: r.query)
    if query_yields:
        lines += ["## 검색어별 수율", "", "| 검색어 | 추출 | 공개 | 수율 |", "| --- | --- | --- | --- |"]
        lines += [f"| {y.key} | {y.extracted} | {y.published} | {_pct(100 * y.rate)} |" for y in query_yields]
        lines.append("")

    lines += ["## 편향 점검", ""]
    collected = Counter(r.dish_type for r in rows if reached(r, "extracted"))
    published = Counter(r.dish_type for r in rows if r.stage == "published")
    total_c, total_p = sum(collected.values()) or 1, sum(published.values()) or 1
    lines += ["| 종류 | 추출한 것 중 | 공개된 것 중 |", "| --- | --- | --- |"]
    for t in taxonomy.types:
        if collected[t.code] or published[t.code]:
            lines.append(f"| {t.label} | {_pct(100 * collected[t.code] / total_c)} | {_pct(100 * published[t.code] / total_p)} |")
    channels = Counter(names.get(channel_key(r), r.channel) for r in rows if r.stage == "published")
    top = channels.most_common(3)
    if top:
        share = 100 * sum(c for _, c in top) / (sum(channels.values()) or 1)
        lines += ["", f"공개 레시피 중 상위 3개 채널 비중: {_pct(share)} ({', '.join(f'{n} {c}' for n, c in top)})."]
    lines.append("")

    lines += ["## 사용자 관점 다양성 (대표 재료 조합)", "",
              "`rules/sample-inventories.json`의 재료 조합으로 바로 만들 수 있는 공개 레시피와 그 종류 수. "
              "재료 관계(relations)는 넣지 않은 보수적인 근사치다.", "",
              "| 재료 조합 | 만들 수 있는 레시피 | 종류 수 | 종류 |", "| --- | --- | --- | --- |"]
    for d in diversity(taxonomy, catalog, rows):
        kinds = ", ".join(f"{taxonomy.label(c).split('(')[0]} {n}" for c, n in d["types"].most_common())
        lines.append(f"| {d['inventory']} | {d['recipes']} | {len(d['types'])} | {kinds or '-'} |")
    lines.append("")
    return "\n".join(lines)


def render_plan(result: dict, taxonomy: Taxonomy) -> str:
    lines = [f"# 다음 수집 계획 (Gemini 호출 {result['budget']}회)", ""]
    if result["blockedTypes"]:
        lines += ["목표 비율을 넘어 신규 수집을 멈춘 종류: " + ", ".join(taxonomy.label(c) for c in result["blockedTypes"])
                  + ". 아래 어떤 수집이든 이 종류로 분류되는 후보는 고르지 않는다.", ""]
    exploit_total = sum(e["calls"] for e in result["exploit"])
    lines += [f"## 활용 {exploit_total}회: 수율이 확인된 채널", "",
              "| 채널 | 호출 | 기대 수율 | 표본 |", "| --- | --- | --- | --- |"]
    lines += [f"| {e['channel']} | {e['calls']} | {_pct(100 * e['expected'])} | {e['sample']} |" for e in result["exploit"]]
    commands = [f"python3 src/discover.py --channel {e['channelId']} --per-channel {e['calls']} --write"
                for e in result["exploit"] if e["channelId"]]
    explore_types = sum(e["calls"] for e in result["exploreTypes"])
    lines += ["", f"## 탐험 {explore_types + result['exploreNewChannels']}회", "",
              f"### 부족한 종류 {explore_types}회", "", "| 종류 | 호출 | 검색어 예 |", "| --- | --- | --- |"]
    lines += [f"| {e['label']} | {e['calls']} | {', '.join(e['queries'][:4]) or '-'} |" for e in result["exploreTypes"]]
    lines += ["", f"### 처음 가 보거나 표본이 적은 채널 {result['exploreNewChannels']}회", "",
              "검색은 구독자 기준만 보고 채널을 가리지 않으므로, 부족한 종류의 다른 검색어로 새 채널을 찾는다. "
              "표본이 적은 채널은 수율과 상관없이 표본이 적은 순서로 보여 준다.", ""]
    if result["unprovenChannels"]:
        lines.append("표본이 적은 채널: " + ", ".join(f"{y.key}({y.published}/{y.extracted})" for y in result["unprovenChannels"]))
    commands += [f"python3 src/discover.py --query \"{e['queries'][0]}\" --per-query {e['calls']} --write"
                 for e in result["exploreTypes"] if e["queries"]]
    spare = [(e["queries"][1], e) for e in result["exploreTypes"] if len(e["queries"]) > 1]
    for index in range(result["exploreNewChannels"]):
        if spare:
            query, _ = spare[index % len(spare)]
            commands.append(f"python3 src/discover.py --query \"{query}\" --per-query 1 --write")
    lines += ["", "실행 명령 (discover는 목표를 넘은 종류의 후보를 제목으로 걸러낸다):", "", "```bash", *commands, "```", ""]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    metrics_parser = sub.add_parser("metrics")
    metrics_parser.add_argument("--write", action="store_true")
    plan_parser = sub.add_parser("plan")
    plan_parser.add_argument("--budget", type=int, default=40)
    args = parser.parse_args(argv)

    taxonomy, catalog = Taxonomy.load(), Catalog.load()
    rows = load_rows(taxonomy)
    if args.command == "metrics":
        report = render_metrics(rows, taxonomy, catalog)
        if args.write:
            REPORT_FILE.parent.mkdir(parents=True, exist_ok=True)
            REPORT_FILE.write_text(report + "\n", encoding="utf-8")
        print(report)
        return 0
    queries = json.loads((RULES_DIR / "dish-types.json").read_text(encoding="utf-8")).get("exploreQueries", {})
    print(render_plan(plan(rows, taxonomy, args.budget, queries), taxonomy))
    return 0


if __name__ == "__main__":
    sys.exit(main())
