"""Apply saved Gemini extractions to the recipe dataset, deterministically.

Run on request only; the pipeline workers never call this. Two steps:

    python3 src/apply.py fetch            # network: Shorts/embed checks and channel metadata,
                                          #   saved into checkpoints and rules/exclusions.json
    python3 src/apply.py plan             # no network: classify and print the report
    python3 src/apply.py plan --write     # also write recipes and reports/latest-apply.md
    python3 src/apply.py plan --promote ID ...   # fill new mappings into those existing drafts
    python3 src/apply.py suggest-aliases  # alias candidates mined from published recipes

The plan step reads only the checkpoints, the dataset and the reviewed rules files, so the same
inputs give the same result. Only clear cases are written; anything that needs a human decision
stays out of the dataset with its reason. See docs/v5/development/pipeline-overhaul.md.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

from recipe_rules import (DATA_DIR, ROOT, RULES_DIR, Catalog, Rules, check_rules, decided, hits_excluded_word, is_derived,
                          is_foreign_unit, is_group_name, load_rules, name_candidate, near_catalog_name, normalize_unit,
                          plain_short_name, resolve, split_alternatives, strip_english, validate_recipe)
from state import STATE_DIR, locked_video, save_video, write_json_atomic
from validator import validate_source_extraction

REPORT_FILE = ROOT / "reports" / "latest-apply.md"
_VIDEO_ID = re.compile(r"(?:shorts/|youtu\.be/|[?&]v=)([A-Za-z0-9_-]{11})")
# Heat or appliance words. A recipe with none of them is flagged for review, never rejected.
_COOKING_WORDS = ("볶", "끓", "굽", "구워", "구운", "삶", "데치", "데쳐", "튀기", "튀겨", "찌고", "찐", "쪄", "부치", "부쳐",
                  "익혀", "익히", "익을", "졸이", "졸여", "조려", "가열", "전자레인지", "전자렌지", "에어프라이어", "오븐",
                  "불에", "불을", "팬에", "냄비", "뚝배기", "프라이팬", "중불", "약불", "강불", "센불", "토치")
_RAW_ALTERNATIVE = re.compile(r"또는|(?<!\d)\s*/\s*(?!\d)|\bor\b")
_RECIPE_FIELDS = ("key", "name", "status", "shortsReference", "ingredients", "requirements", "steps", "sourceTitle",
                  "sourceChannelName", "sourceChannelId", "sourceChannelThumbnailUrl", "sourceMetadataFetchedAt")

PUBLISH = "PUBLISH"  # written as PUBLISHED
WAIT_MASTER = "WAIT_MASTER"  # written as DRAFT: only catalog ingredients are missing
REVIEW = "REVIEW"  # needs a human decision; not written
SKIP = "SKIP"  # will not become a recipe; not written
LABELS = {PUBLISH: "공개", WAIT_MASTER: "재료가 추가되면 공개 가능(초안으로 반영)", REVIEW: "사람 확인 필요(반영 안 함)",
          SKIP: "반영 안 함"}


@dataclass
class Outcome:
    video_id: str
    title: str
    outcome: str
    reasons: list[str] = field(default_factory=list)
    unresolved: list[str] = field(default_factory=list)
    recipe: dict | None = None


# ---------- reading ----------

def video_id_of(reference: str) -> str | None:
    match = _VIDEO_ID.search(reference or "")
    return match.group(1) if match else None


def recipe_key(video_id: str) -> str:
    """Existing convention: 'video-' + lowercased ID, '_' -> '-'. Lowercasing can collide; callers check."""
    return "video-" + re.sub(r"-+", "-", video_id.lower().replace("_", "-")).strip("-")


def load_dataset(data_dir: Path = DATA_DIR) -> dict[str, tuple[Path, dict]]:
    """Existing recipes by video ID (matched by shortsReference, never by key)."""
    found = {}
    for path in sorted((data_dir / "recipes").glob("*.json")):
        recipe = json.loads(path.read_text(encoding="utf-8"))
        video_id = video_id_of(recipe.get("shortsReference", ""))
        if video_id:
            found[video_id] = (path, recipe)
    return found


def ready_checkpoints(state_dir: Path = STATE_DIR) -> dict[str, dict]:
    result = {}
    for path in sorted(state_dir.glob("*.json")):
        if len(path.stem) != 11:
            continue
        try:
            state = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            continue
        if state.get("status") == "EXTRACTION_READY" and isinstance((state.get("extraction") or {}).get("result"), dict):
            result[path.stem] = state
    return result


# ---------- classification (pure) ----------

def looks_like_cooking(steps: list[str]) -> bool:
    return any(word in step for step in steps for word in _COOKING_WORDS)


def deleted_video_ids(repo_root: Path = DATA_DIR.parent) -> dict[str, str]:
    """Videos whose recipe file was deleted at some point in git history -> commit.

    A deleted recipe was removed by a person on purpose, so it must not come back unless
    rules/exclusions.json or the dataset says otherwise. Read from git so the check needs no list
    kept by hand; a repository without history simply yields nothing.
    """
    def git(*args: str) -> str:
        return subprocess.run(["git", "-C", str(repo_root), *args], capture_output=True, text=True).stdout

    found: dict[str, str] = {}
    commit = None
    for line in git("log", "--diff-filter=D", "--format=commit %H", "--name-only", "--", "data/recipes/*.json").splitlines():
        if line.startswith("commit "):
            commit = line.split()[1]
        elif line.strip() and commit:
            video_id = video_id_of(git("show", f"{commit}^:{line.strip()}"))
            if video_id:
                found.setdefault(video_id, commit[:7])
    return found


def map_ingredients(result: dict, rules: Rules, catalog: Catalog, video_id: str = "") -> tuple[list[dict], list[dict], list[str], list[str]]:
    """(ingredients, requirements, unresolved required names, review notes) for one extraction."""
    ingredients, requirements, unresolved, notes = [], [], [], []
    for item in result["ingredients"]:
        display = (item.get("displayName") or item.get("rawText") or "").strip()
        raw = item.get("rawText") or display
        optional = bool(item.get("optional")) or is_derived(display, rules)
        mapping = decided(video_id, item["sourceId"], display, rules, catalog) or resolve(display, rules, catalog)
        ingredients.append({
            "key": item["sourceId"],
            "variant": mapping.variant if mapping else None,
            "acceptedOwnedVariants": list(mapping.accepted) if mapping else [],
            "displayName": mapping.display_name if mapping else display,
            "rawText": raw,
            "amount": item.get("amount"),
            "unit": normalize_unit(item.get("unit"), rules),
            "optional": optional,
        })
        if optional:
            continue
        if mapping:
            requirements.append({"options": [{"ingredient": item["sourceId"], "substitutes": [],
                                              "allowedVariants": list(mapping.allowed)}]})
        else:
            unresolved.append(display)
        if not (mapping and mapping.via == "decision"):
            notes.extend(ingredient_notes(display, raw, mapping, rules, catalog))
    return ingredients, requirements, unresolved, notes


def ingredient_notes(display: str, raw: str, mapping, rules: Rules, catalog: Catalog) -> list[str]:
    """Reasons a required ingredient needs a human, even when it mapped."""
    if mapping is not None and mapping.via == "alternative":
        return [f"'{display}'을 대체 가능 재료로 묶음: 같은 재료인지 대체인지 확인"]
    if split_alternatives(strip_english(display)):
        return [f"'{display}'은 대체 재료 표기인데 일부가 카탈로그에 없음: 어느 쪽으로 할지 확인"]
    if _RAW_ALTERNATIVE.search(raw):
        return [f"원문 '{raw}'에 다른 재료 표기가 있음: 대체 재료로 넣을지 확인"]
    if mapping is None and is_group_name(display, catalog):
        return [f"'{display}'은 여러 종류를 묶은 이름: 어떤 종류를 인정할지 확인"]
    if mapping is None and not hits_excluded_word(display, rules):
        near = near_catalog_name(display, catalog)
        if near:
            return [f"'{display}'은 카탈로그의 '{near}'와 비슷함: 같은 재료면 별칭, 아니면 새 재료"]
    return []


_QUANTITY_WORDS = re.compile(r"계량|분량|중량|정량|수량|수치|단위|개수|무게|정확한 양|의 양|양은|양이|양과|양을")
_CONTENT_WORDS = re.compile(r"종류|명칭|부위|대신|넣어도|여부|배합|추정|연출|시간|온도|불 세기|순서|공개되지")


def is_quantity_only_note(note: str) -> bool:
    """A Gemini note that only says an amount or unit was not given. Amounts may stay empty, so it does
    not block publishing (user decision 2026-11-22); notes about kind, part, substitutes or method still do."""
    return bool(_QUANTITY_WORDS.search(note)) and not _CONTENT_WORDS.search(note)


def quality_review(ingredients: list[dict], steps: list[str], state: dict | None, meta: dict, rules: Rules) -> list[str]:
    """Checks shared by new recipes and draft promotions (spec: 자동 품질 검사)."""
    review = []
    checks = (state or {}).get("applyChecks") or {}
    if checks.get("short") is not True or checks.get("embeddable") is not True:
        review.append("쇼츠·임베드 여부를 아직 확인하지 않음(apply.py fetch)")
    gemini_notes = ((state or {}).get("extraction") or {}).get("result", {}).get("unresolved") or []
    for note in gemini_notes:
        if not is_quantity_only_note(note):
            review.append(f"Gemini가 남긴 불확실한 점: {note}")
    required_count = sum(1 for item in ingredients if not item["optional"])
    if required_count < rules.min_required:
        review.append(f"필수 재료가 {required_count}개뿐임(기준 {rules.min_required}개 이상)")
    if not looks_like_cooking(steps):
        review.append("가열·조리 단계가 보이지 않음(섞기·담기만인지 확인)")
    if not (meta.get("sourceChannelName") and meta.get("sourceChannelThumbnailUrl")):
        review.append("채널 이름·사진이 없음")
    foreign = sorted({item["unit"] for item in ingredients if is_foreign_unit(item["unit"])})
    if foreign:
        review.append("영어 단위가 남아 있음: " + ", ".join(foreign))
    return review


def build(video_id: str, state: dict, rules: Rules, catalog: Catalog, taken: dict[str, str],
          name_counts: Counter, deleted: dict[str, str] | None = None) -> Outcome:
    """Classify one new video. `taken` maps existing recipe keys to their video IDs."""
    result = state["extraction"]["result"]
    title = (result.get("title") or "").strip()
    outcome = Outcome(video_id, title, SKIP)

    if video_id in rules.exclusions:
        entry = rules.exclusions[video_id]
        outcome.reasons.append(f"제외 목록: {entry.get('category')} {entry.get('note', '')}".strip())
        return outcome
    if deleted and video_id in deleted:
        outcome.reasons.append(f"git 기록상 사람이 지운 레시피(커밋 {deleted[video_id]}): exclusions.json에 이유를 기록할 것")
        return outcome
    shape_errors = validate_source_extraction(result)
    if shape_errors or not result.get("ingredients"):
        outcome.reasons.append("추출 결과 형식 오류: " + ("; ".join(shape_errors) or "재료 없음"))
        return outcome

    ingredients, requirements, unresolved, notes = map_ingredients(result, rules, catalog, video_id)
    outcome.unresolved = unresolved
    policy_hits = [name for name in unresolved
                   if hits_excluded_word(name, rules) and not split_alternatives(strip_english(name))]
    if policy_hits:
        outcome.reasons.append("자취생 기준에서 뺀 재료가 필요함: " + ", ".join(policy_hits))
        return outcome

    steps = [step["text"].strip() for step in result["steps"]]
    meta = state.get("sourceMetadata") or {}
    review = notes + quality_review(ingredients, steps, state, meta, rules)
    name = rules.names.get(video_id) or plain_short_name(title, rules)
    if not name:
        review.append(f"이름 승인 필요(rules/names.json, 후보: {name_candidate(title) or '-'})")
    elif name_counts[name] >= 2:
        review.append(f"같은 이름 '{name}' 레시피가 이미 {name_counts[name]}개 있음")
    key = recipe_key(video_id)
    if key in taken and taken[key] != video_id:
        review.append(f"레시피 키 '{key}'가 다른 영상({taken[key]})과 겹침")

    recipe = {"key": key, "name": name or title, "status": "DRAFT" if unresolved else "PUBLISHED",
              "shortsReference": f"https://www.youtube.com/shorts/{video_id}",
              "ingredients": ingredients, "requirements": requirements, "steps": steps}
    for meta_key in _RECIPE_FIELDS[7:]:
        if meta.get(meta_key):
            recipe[meta_key] = meta[meta_key]
    errors = validate_recipe(recipe, catalog)
    if errors:
        review.append("검증 실패: " + "; ".join(errors[:3]))
    outcome.recipe = recipe

    if review:
        outcome.outcome = REVIEW
        outcome.reasons.extend(review)
    elif unresolved:
        outcome.outcome = WAIT_MASTER
        outcome.reasons.append("카탈로그에 없는 필수 재료: " + ", ".join(unresolved))
    else:
        outcome.outcome = PUBLISH
    return outcome


@dataclass
class Promotion:
    video_id: str
    recipe: dict
    filled: list[str]
    unresolved: list[str]
    review: list[str]

    @property
    def ready(self) -> bool:
        return bool(self.filled) and not self.unresolved and not self.review


def fill_draft(draft: dict, rules: Rules, catalog: Catalog, video_id: str = "") -> tuple[dict, list[str], list[str]]:
    """Fill mappings only where the draft has none; hand-made mappings, names and steps are kept.

    A filled ingredient also takes the catalog display name (guideline 2). Returns
    (updated recipe, filled descriptions, required names that still need a person).
    """
    updated = json.loads(json.dumps(draft))
    roles = {option["ingredient"] for requirement in updated["requirements"] for option in requirement["options"]}
    filled, unresolved = [], []
    for item in updated["ingredients"]:
        if item["optional"] or item.get("variant") or item.get("acceptedOwnedVariants"):
            continue
        mapping = decided(video_id, item["key"], item["displayName"], rules, catalog)
        if mapping is None:
            mapping = resolve(item["displayName"], rules, catalog)
            if not mapping or ingredient_notes(item["displayName"], item.get("rawText") or "", mapping, rules, catalog):
                unresolved.append(item["displayName"])
                continue
        before = item["displayName"]
        item["variant"] = mapping.variant
        item["acceptedOwnedVariants"] = list(mapping.accepted)
        item["displayName"] = mapping.display_name
        filled.append(before if before == mapping.display_name else f"{before}→{mapping.display_name}")
        if item["key"] not in roles:
            updated["requirements"].append({"options": [{"ingredient": item["key"], "substitutes": [],
                                                         "allowedVariants": list(mapping.allowed)}]})
    if not unresolved:
        updated["status"] = "PUBLISHED"
    return updated, filled, unresolved


def evaluate_draft(video_id: str, draft: dict, state: dict | None, rules: Rules, catalog: Catalog) -> Promotion:
    updated, filled, unresolved = fill_draft(draft, rules, catalog, video_id)
    review = []
    if not unresolved:
        if state is None:
            review.append("체크포인트가 없음")
        review += quality_review(updated["ingredients"], updated["steps"], state, updated, rules)
        if video_id in rules.exclusions:
            review.append("제외 목록에 있음")
        review += ["검증 실패: " + e for e in validate_recipe(updated, catalog)[:3]]
    return Promotion(video_id, updated, filled, unresolved, review)


def blocker_kind(name: str, rules: Rules, catalog: Catalog) -> str:
    if hits_excluded_word(name, rules):
        return "자취생 기준 제외 단어"
    if is_group_name(name, catalog):
        return "묶음 이름(레시피별 판단)"
    if split_alternatives(strip_english(name)):
        return "대체 재료 표기"
    near = near_catalog_name(name, catalog)
    return f"카탈로그의 '{near}'와 비슷함" if near else ""


def unlock_ranking(blockers: list[list[str]]) -> list[tuple[str, int, int]]:
    """(ingredient, drafts it alone blocks, drafts it appears in as a blocker)."""
    sole, total = Counter(), Counter()
    for names in blockers:
        unique = sorted(set(names))
        for name in unique:
            total[name] += 1
        if len(unique) == 1:
            sole[unique[0]] += 1
    return sorted(((n, sole[n], total[n]) for n in total), key=lambda r: (-r[1], -r[2], r[0]))


def conflicts(dataset: dict[str, tuple[Path, dict]], rules: Rules) -> list[str]:
    """Published recipes that a current rule would not publish. Reported only; deleting needs a human."""
    found = []
    for video_id, (path, recipe) in sorted(dataset.items()):
        if recipe.get("status") != "PUBLISHED":
            continue
        if video_id in rules.exclusions:
            found.append(f"`{path.name}` {recipe['name']}: 제외 목록에 있음({rules.exclusions[video_id].get('category')})")
        required = sum(1 for item in recipe["ingredients"] if not item["optional"])
        if required < rules.min_required:
            found.append(f"`{path.name}` {recipe['name']}: 필수 재료 {required}개")
    return found


# ---------- report ----------

def render_report(outcomes: list[Outcome], promotions: list[Promotion], ranking, kinds: dict[str, str],
                  found_conflicts, written: str) -> str:
    counts = Counter(o.outcome for o in outcomes)
    ready = [p for p in promotions if p.ready]
    held = [p for p in promotions if p.filled and not p.unresolved and p.review]
    lines = ["# 레시피 반영 보고서", "", f"- 실행: {written}",
             "- 새 영상: " + ", ".join(f"{LABELS[k]} {counts.get(k, 0)}" for k in (PUBLISH, WAIT_MASTER, REVIEW, SKIP)),
             f"- 기존 초안: 이제 공개 가능 {len(ready)}, 매핑은 채워지지만 확인 필요 {len(held)}", ""]
    for kind in (PUBLISH, REVIEW, WAIT_MASTER, SKIP):
        items = [o for o in outcomes if o.outcome == kind]
        if not items:
            continue
        lines += [f"## {LABELS[kind]} ({len(items)})", ""]
        for o in items:
            name = (o.recipe or {}).get("name", "")
            lines.append(f"- `{o.video_id}` {o.title}" + (f" → **{name}**" if kind == PUBLISH else ""))
            lines += [f"  - {reason}" for reason in o.reasons]
        lines.append("")
    if ready:
        lines += ["## 기존 초안 중 이제 공개 가능 (`plan --promote <영상 ID>`로 반영)", ""]
        lines += [f"- `{p.video_id}` {p.recipe['name']}: {', '.join(p.filled)} 연결" for p in ready]
        lines.append("")
    if held:
        lines += ["## 기존 초안: 매핑은 채워지지만 확인 필요", ""]
        for p in held:
            lines.append(f"- `{p.video_id}` {p.recipe['name']}: {', '.join(p.filled)} 연결")
            lines += [f"  - {reason}" for reason in p.review]
        lines.append("")
    if ranking:
        lines += ["## 초안을 막고 있는 재료", "", "재료를 추가하기 전에 종류를 본다. 종류가 비어 있는 것만 새 재료 후보다.", "",
                  "| 재료 | 이 재료만 없는 초안 | 이 재료가 막는 초안 | 종류 |", "| --- | --- | --- | --- |"]
        lines += [f"| {n} | {s} | {t} | {kinds.get(n, '')} |" for n, s, t in ranking[:50]]
        lines.append("")
    if found_conflicts:
        lines += ["## 현재 규칙과 맞지 않는 공개 레시피 (확인만, 자동으로 지우지 않음)", ""]
        lines += [f"- {line}" for line in found_conflicts]
        lines.append("")
    return "\n".join(lines)


def ordered(recipe: dict) -> dict:
    return {key: recipe[key] for key in _RECIPE_FIELDS if key in recipe}


# ---------- commands ----------

def plan(args, rules: Rules, catalog: Catalog) -> int:
    dataset = load_dataset()
    checkpoints = ready_checkpoints()
    deleted = {v: c for v, c in deleted_video_ids().items() if v not in dataset and v not in rules.exclusions}
    wanted = set(args.video) if args.video else None
    taken = {path.stem: video_id for video_id, (path, _) in dataset.items()}
    name_counts = Counter(recipe["name"] for _, recipe in dataset.values())

    outcomes = []
    for video_id, state in checkpoints.items():
        if video_id in dataset or (wanted and video_id not in wanted):
            continue
        outcome = build(video_id, state, rules, catalog, taken, name_counts, deleted)
        if outcome.outcome in (PUBLISH, WAIT_MASTER):
            name_counts[outcome.recipe["name"]] += 1
            taken[outcome.recipe["key"]] = video_id
        outcomes.append(outcome)

    promotions = [evaluate_draft(video_id, recipe, checkpoints.get(video_id), rules, catalog)
                  for video_id, (_, recipe) in dataset.items() if recipe.get("status") == "DRAFT"]
    blockers = [o.unresolved for o in outcomes if o.outcome == WAIT_MASTER] + [p.unresolved for p in promotions if p.unresolved]
    ranking = unlock_ranking(blockers)
    kinds = {name: blocker_kind(name, rules, catalog) for name, _, _ in ranking}

    by_id = {p.video_id: p for p in promotions}
    if args.promote:
        not_ready = [v for v in args.promote if v not in by_id or not by_id[v].ready]
        if not_ready:
            print("공개할 수 없는 초안: " + ", ".join(not_ready) + " (보고서의 '이제 공개 가능' 목록만 된다)", file=sys.stderr)
            return 2
    mode = "새 레시피 반영(--write)" if args.write else f"초안 공개(--promote {len(args.promote)}개)" if args.promote else "미리보기"
    report = render_report(outcomes, promotions, ranking, kinds, conflicts(dataset, rules), mode)
    if args.write:
        new = [o.recipe for o in outcomes if o.outcome in (PUBLISH, WAIT_MASTER)]
        for recipe in new:
            path = DATA_DIR / "recipes" / f"{recipe['key']}.json"
            if path.exists():
                raise SystemExit(f"{path} already exists; refusing to overwrite")
            write_json_atomic(path, ordered(recipe))
        print(f"새 레시피 {len(new)}개 반영.")
    for video_id in args.promote:
        path = dataset[video_id][0]
        recipe = by_id[video_id].recipe
        write_json_atomic(path, {key: recipe[key] for key in dataset_keys_in_order(path, recipe)})
    if args.write or args.promote:
        write_json_atomic_text(REPORT_FILE, report + "\n")
        print(f"보고서: {REPORT_FILE}. 반영 결과는 git diff로 확인한다.")
    print(report)
    return 0


def dataset_keys_in_order(path: Path, recipe: dict) -> list[str]:
    """Keep the existing file's field order so a promotion diff shows only real changes."""
    original = json.loads(path.read_text(encoding="utf-8"))
    return [key for key in original if key in recipe] + [key for key in recipe if key not in original]


def write_json_atomic_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(text, encoding="utf-8")
    temporary.replace(path)


def _embeddable(video_id: str) -> bool | None:
    """oEmbed answers for playable videos; 401/403/404 mean blocked or gone. Anything else is unknown."""
    from urllib.error import HTTPError, URLError
    from urllib.parse import quote
    from youtube import _get_text
    url = ("https://www.youtube.com/oembed?url="
           + quote("https://www.youtube.com/shorts/" + video_id, safe="") + "&format=json")
    try:
        _get_text(url)
        return True
    except HTTPError as error:
        return False if error.code in (401, 403, 404) else None
    except (URLError, TimeoutError, OSError):
        return None


def fetch_targets(rules: Rules, catalog: Catalog, wanted: set[str] | None) -> list[str]:
    """New videos and existing drafts that could still become recipes."""
    dataset = load_dataset()
    targets = []
    for video_id, state in ready_checkpoints().items():
        if video_id in rules.exclusions or (wanted and video_id not in wanted):
            continue
        if video_id in dataset:
            if dataset[video_id][1].get("status") == "DRAFT":
                targets.append(video_id)
            continue
        result = state["extraction"]["result"]
        if validate_source_extraction(result) or not result.get("ingredients"):
            continue
        _, _, unresolved, _ = map_ingredients(result, rules, catalog, video_id)
        if any(hits_excluded_word(n, rules) and not split_alternatives(strip_english(n)) for n in unresolved):
            continue
        targets.append(video_id)
    return targets


def check_video(video_id: str, checks: dict, meta: dict, is_short, fetch_metadata) -> tuple[dict, dict]:
    """Ask YouTube only what is still unknown. Unknown answers are left out so the next run asks again."""
    checks, meta = dict(checks), dict(meta)
    if checks.get("short") is None:
        value = is_short(video_id)
        if value is not None:
            checks["short"] = value
    if checks.get("short") is True and checks.get("embeddable") is None:
        value = _embeddable(video_id)
        if value is not None:
            checks["embeddable"] = value
    if checks.get("short") and checks.get("embeddable") and not (
            meta.get("sourceChannelName") and meta.get("sourceChannelThumbnailUrl")):
        fetched = fetch_metadata(video_id)
        merged = {**fetched, **{k: v for k, v in meta.items() if v}}
        if any(merged.get(k) for k in ("sourceChannelName", "sourceChannelThumbnailUrl")):
            meta = merged
    return checks, meta


def fetch(args, rules: Rules, catalog: Catalog) -> int:
    """Record definitive YouTube facts in checkpoints. Network calls run outside the checkpoint lock."""
    from youtube import fetch_source_metadata, is_short
    targets = fetch_targets(rules, catalog, set(args.video) if args.video else None)
    new_exclusions = {}
    for video_id in targets:
        current = json.loads((STATE_DIR / f"{video_id}.json").read_text(encoding="utf-8"))
        old_checks, old_meta = current.get("applyChecks") or {}, current.get("sourceMetadata") or {}
        checks, meta = check_video(video_id, old_checks, old_meta, is_short, fetch_source_metadata)
        if checks != old_checks or meta != old_meta:
            with locked_video(video_id) as state:
                if state.get("status") != "EXTRACTION_READY":
                    print(video_id, "상태가 바뀌어 건너뜀")
                    continue
                checks["checkedAt"] = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
                state["applyChecks"] = checks
                if meta:
                    state["sourceMetadata"] = meta
                save_video(state)
        if checks.get("short") is False:
            new_exclusions[video_id] = {"category": "NOT_SHORT", "note": "shorts 주소가 /watch로 넘어감", "source": "apply.py fetch"}
        elif checks.get("embeddable") is False:
            new_exclusions[video_id] = {"category": "NOT_EMBEDDABLE", "note": "oEmbed가 401/403/404로 응답", "source": "apply.py fetch"}
        print(video_id, checks)
    if new_exclusions:
        path = RULES_DIR / "exclusions.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["videos"] = dict(sorted({**new_exclusions, **data["videos"]}.items()))
        write_json_atomic(path, data)
    print(f"확인한 영상 {len(targets)}개, 새로 제외 {len(new_exclusions)}개")
    return 0


def suggest_aliases(rules: Rules, catalog: Catalog) -> int:
    """Alias candidates from published recipes, for a human to copy into rules/aliases.json.

    Keyed on the extracted display name the tool actually resolves. A name is suggested only
    when every published recipe mapped it to the same single exact variant; names that recipes
    mapped differently are listed apart, because those are per-recipe decisions, not aliases.
    """
    seen: dict[str, Counter] = {}
    names = {key: name for key, name in catalog.variant_by_name.values()}
    for _, recipe in load_dataset().values():
        if recipe.get("status") != "PUBLISHED":
            continue
        for item in recipe["ingredients"]:
            display = item["displayName"].strip()
            if item["optional"] or resolve(display, rules, catalog):
                continue
            target = item.get("variant") or "+".join(sorted(item.get("acceptedOwnedVariants") or []))
            if target:
                seen.setdefault(display, Counter())[target] += 1
    print("# 모든 공개 레시피가 같은 재료로 연결한 이름 (검토 후 rules/aliases.json에 추가)")
    for display, targets in sorted(seen.items(), key=lambda kv: -sum(kv[1].values())):
        if len(targets) == 1 and "+" not in next(iter(targets)):
            target = next(iter(targets))
            print(f'    "{display}": "{names.get(target, target)}",  # {targets[target]}개')
    print("# 레시피마다 다르게 연결한 이름 (별칭 아님, 레시피별 판단)")
    for display, targets in sorted(seen.items()):
        if len(targets) > 1 or "+" in next(iter(targets)):
            print(f"    {display}: " + ", ".join(f"{t} {n}개" for t, n in targets.most_common()))
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    fetch_parser = sub.add_parser("fetch", help="network checks saved into checkpoints")
    fetch_parser.add_argument("--video", nargs="*")
    plan_parser = sub.add_parser("plan", help="classify without network")
    plan_parser.add_argument("--video", nargs="*")
    plan_parser.add_argument("--write", action="store_true", help="write new recipes and the report")
    plan_parser.add_argument("--promote", nargs="+", default=[], metavar="VIDEO_ID",
                             help="publish only these existing drafts (from the report's ready list)")
    sub.add_parser("suggest-aliases", help="print alias candidates from published recipes")
    args = parser.parse_args(argv)

    rules, catalog = load_rules(), Catalog.load()
    problems = check_rules(rules, catalog)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 2
    if args.command == "fetch":
        return fetch(args, rules, catalog)
    if args.command == "suggest-aliases":
        return suggest_aliases(rules, catalog)
    return plan(args, rules, catalog)


if __name__ == "__main__":
    sys.exit(main())
