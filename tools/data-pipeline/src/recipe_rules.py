"""Pure, deterministic rules for turning a saved Gemini extraction into a recipe.

No network or file writes here. The apply CLI (apply.py) wires these rules to
checkpoints, YouTube checks and the dataset. See docs/v5/development/pipeline-overhaul.md.
"""

from __future__ import annotations

import json
import re
from datetime import datetime
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RULES_DIR = ROOT / "rules"
REPO_ROOT = ROOT.parents[1]
DATA_DIR = REPO_ROOT / "data"


def _norm(text: str | None) -> str:
    """Comparison key: drop spaces and simple punctuation."""
    return re.sub(r"[\s()\[\]·,/]", "", text or "")


@dataclass(frozen=True)
class Rules:
    aliases: dict[str, str]
    excluded_words: tuple[str, ...]
    derived_words: tuple[str, ...]
    unit_aliases: dict[str, str]
    min_required: int
    max_name_length: int
    names: dict[str, str]
    exclusions: dict[str, dict]


def load_rules(rules_dir: Path = RULES_DIR) -> Rules:
    def read(name: str, default: dict) -> dict:
        path = rules_dir / name
        return json.loads(path.read_text(encoding="utf-8")) if path.exists() else default

    aliases = read("aliases.json", {"aliases": {}})["aliases"]
    policy = read("policy.json", {})
    names = read("names.json", {"names": {}})["names"]
    exclusions = read("exclusions.json", {"videos": {}})["videos"]
    return Rules(
        aliases={_norm(k): v for k, v in aliases.items()},
        excluded_words=tuple(policy.get("excludedIngredientWords", {}).get("words", [])),
        derived_words=tuple(policy.get("derivedIngredientWords", {}).get("words", [])),
        unit_aliases=dict(policy.get("unitAliases", {})),
        min_required=int(policy.get("minRequiredIngredients", 4)),
        max_name_length=int(policy.get("maxNameLength", 9)),
        names=dict(names),
        exclusions=dict(exclusions),
    )


@dataclass(frozen=True)
class Mapping:
    variant: str | None
    accepted: tuple[str, ...]
    display_name: str
    allowed: tuple[str, ...] = ()
    via: str = "catalog"  # catalog | alias | alternative


@dataclass
class Catalog:
    """Ingredient catalog: exact variant names, catalog aliases and group membership."""

    variant_by_name: dict[str, tuple[str, str]]  # norm(name or alias) -> (variant key, display name)
    group_of: dict[str, str]  # variant key -> group key
    group_names: frozenset[str] = frozenset()  # norm(name) of groups with several variants

    @classmethod
    def load(cls, data_dir: Path = DATA_DIR) -> "Catalog":
        groups = json.loads((data_dir / "ingredients.json").read_text(encoding="utf-8"))["ingredients"]
        by_name: dict[str, tuple[str, str]] = {}
        group_of: dict[str, str] = {}
        multi: set[str] = set()
        for group in groups:
            for variant in group["variants"]:
                group_of[variant["key"]] = group["key"]
                by_name[_norm(variant["name"])] = (variant["key"], variant["name"])
                for alias in variant.get("aliases", []):
                    by_name.setdefault(_norm(alias), (variant["key"], variant["name"]))
            if len(group["variants"]) == 1:
                only = group["variants"][0]
                by_name.setdefault(_norm(group["name"]), (only["key"], only["name"]))
            elif _norm(group["name"]) not in by_name:
                multi.add(_norm(group["name"]))
        return cls(by_name, group_of, frozenset(multi))


def check_rules(rules: Rules, catalog: Catalog) -> list[str]:
    """Every alias must point at a catalog name, so a renamed catalog entry fails loudly."""
    return [f"aliases.json: '{source}' -> '{target}' is not a catalog name"
            for source, target in rules.aliases.items() if _norm(target) not in catalog.variant_by_name]


_ENGLISH_PAREN = re.compile(r"^(.*?)\s*\(([A-Za-z][A-Za-z ,'\-]*)\)\s*$")
_ALTERNATIVE = re.compile(r"^(.*?)\s*(?:\(\s*(?:또는|or)\s+([^)]+)\)|\s(?:또는|or)\s(.+))\s*$")


def strip_english(name: str) -> str:
    """'버터 (butter)' -> '버터'. Only a pure-English parenthesis, which is a translation."""
    match = _ENGLISH_PAREN.match(name or "")
    return match.group(1).strip() if match else (name or "")


def split_alternatives(name: str) -> list[str] | None:
    """'A (또는 B)', 'A 또는 B', 'A or B' -> [A, B]."""
    match = _ALTERNATIVE.match(name or "")
    if not match:
        return None
    first = match.group(1).strip()
    second = next(group for group in match.groups()[1:] if group).strip()
    return [first, second] if first and second else None


def _resolve_single(name: str, rules: Rules, catalog: Catalog) -> Mapping | None:
    key = _norm(strip_english(name))
    via = "catalog"
    if key in rules.aliases:
        key, via = _norm(rules.aliases[key]), "alias"
    if key in catalog.variant_by_name:
        variant, display = catalog.variant_by_name[key]
        return Mapping(variant, (), display, via=via)
    return None


def resolve(name: str, rules: Rules, catalog: Catalog) -> Mapping | None:
    """Map an extracted display name to an owned item, or None if unresolved.

    Only reviewed data is used: exact catalog names, catalog aliases and
    rules/aliases.json. Mappings from other recipes are never reused, because
    every recipe-local mapping is decided on its own (docs/v3 dataset schema).
    Alternatives keep the first option as the exact variant and add the others
    as allowed (same group) or accepted (other group) variants; they are marked
    via="alternative" so the caller sends them to human review.
    """
    parts = split_alternatives(strip_english(name))
    if parts:
        found = [_resolve_single(p, rules, catalog) for p in parts]
        if not all(found):
            return None
        first = found[0]
        allowed, accepted = [], []
        for other in found[1:]:
            if other.variant == first.variant:
                continue
            same_group = catalog.group_of.get(other.variant) == catalog.group_of.get(first.variant)
            (allowed if same_group else accepted).append(other.variant)
        return Mapping(first.variant, tuple(accepted), first.display_name, tuple(allowed), via="alternative")
    return _resolve_single(name, rules, catalog)


def is_group_name(name: str, catalog: Catalog) -> bool:
    """A name like '간장' that names a group with several kinds: which kinds count is a per-recipe decision."""
    return _norm(strip_english(name)) in catalog.group_names


_UNIT_TRANSLATION = re.compile(r"^(.*[가-힣].*?)\s*\([A-Za-z][A-Za-z .'-]*\)$")
_METRIC_UNITS = frozenset({"g", "kg", "mg", "ml", "mL", "L", "l", "cc", "cm"})


def normalize_unit(unit: str | None, rules: Rules) -> str | None:
    """Only the unit changes; rawText and steps stay as extracted. '스푼 (spoons)' -> '스푼'."""
    if unit is None:
        return None
    unit = unit.strip()
    match = _UNIT_TRANSLATION.match(unit)
    if match:
        unit = match.group(1).strip()
    return rules.unit_aliases.get(unit, unit)


def is_foreign_unit(unit: str | None) -> bool:
    """A unit with Latin letters that is not a metric unit (guideline 7)."""
    return bool(unit) and bool(re.search(r"[A-Za-z]", unit)) and unit not in _METRIC_UNITS


def near_catalog_name(name: str, catalog: Catalog) -> str | None:
    """A catalog name the unresolved name probably means (contains it, or is spelled almost the same).

    Only a hint for the report; never used to map.
    """
    import difflib
    key = _norm(strip_english(name))
    if len(key) < 2:
        return None
    names = sorted(catalog.variant_by_name)
    contained = [n for n in names if len(n) >= 2 and (n in key or key in n)]
    if contained:
        best = max(contained, key=lambda n: (len(n), n))
        return catalog.variant_by_name[best][1]
    close = difflib.get_close_matches(key, names, n=1, cutoff=0.66)
    return catalog.variant_by_name[close[0]][1] if close else None


def is_derived(name: str, rules: Rules) -> bool:
    return any(word in (name or "") for word in rules.derived_words)


def hits_excluded_word(name: str, rules: Rules) -> bool:
    return any(word in (name or "") for word in rules.excluded_words)


_MODIFIERS = ("초간단", "역대급", "황금레시피", "레시피", "만들기", "만드는 법", "만드는법", "존맛", "꿀맛", "인생", "비장의", "#shorts", "shorts")


def name_candidate(title: str) -> str:
    """Shorten a video title toward the product naming rule. Never trusted blindly."""
    text = re.sub(r"\([^)]*\)|\[[^\]]*\]|#\S+", " ", title or "")
    text = re.sub(r"\d+\s*분", " ", text)
    for word in _MODIFIERS:
        text = text.replace(word, " ")
    return re.sub(r"\s+", " ", text).strip(" -|·,!?.")


_PLAIN_NAME = re.compile(r"^[가-힣A-Za-z0-9 ]+$")


def plain_short_name(title: str, rules: Rules) -> str | None:
    """A title usable as a name without review: short, letters and digits only."""
    text = (title or "").strip()
    return text if 0 < len(text) <= rules.max_name_length and _PLAIN_NAME.match(text) else None


_RECIPE_KEYS = frozenset({"key", "name", "status", "shortsReference", "ingredients", "requirements", "steps",
                          "sourceTitle", "sourceChannelName", "sourceChannelId", "sourceChannelThumbnailUrl",
                          "sourceMetadataFetchedAt"})
_INGREDIENT_KEYS = frozenset({"key", "variant", "acceptedOwnedVariants", "displayName", "rawText", "amount", "unit",
                              "optional"})
_KEBAB = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def validate_recipe(recipe: dict, catalog: Catalog) -> list[str]:
    """Mirror of the backend DatasetLoader checks for one final recipe file."""
    errors = []

    def text(value) -> bool:
        return isinstance(value, str) and value.strip() != ""

    if not (text(recipe.get("key")) and _KEBAB.match(recipe["key"])):
        errors.append("key must be lowercase ASCII kebab-case")
    for field_name in ("name", "shortsReference"):
        if not text(recipe.get(field_name)):
            errors.append(f"{field_name} must not be blank")
    status = recipe.get("status")
    if status not in ("DRAFT", "PUBLISHED"):
        errors.append("status must be DRAFT or PUBLISHED")
    fetched = recipe.get("sourceMetadataFetchedAt")
    if fetched:
        try:
            parsed = datetime.fromisoformat(fetched.replace("Z", "+00:00"))
            if parsed.utcoffset() is None or parsed.utcoffset().total_seconds() != 0:
                errors.append("sourceMetadataFetchedAt must be a UTC timestamp")
        except ValueError:
            errors.append("sourceMetadataFetchedAt must be an ISO-8601 timestamp")
    unknown = set(recipe) - _RECIPE_KEYS
    if unknown:
        errors.append("unknown fields: " + ", ".join(sorted(unknown)))

    by_key = {}
    for index, item in enumerate(recipe.get("ingredients") or []):
        path = f"ingredients[{index}]"
        key = item.get("key")
        if not (text(key) and _KEBAB.match(key)):
            errors.append(f"{path}.key must be lowercase ASCII kebab-case")
        if key in by_key:
            errors.append(f"{path}.key duplicate '{key}'")
        by_key[key] = item
        if set(item) - _INGREDIENT_KEYS:
            errors.append(f"{path} unknown fields: " + ", ".join(sorted(set(item) - _INGREDIENT_KEYS)))
        variant = item.get("variant")
        if variant is not None and variant not in catalog.group_of:
            errors.append(f"{path}.variant unknown '{variant}'")
        accepted = item.get("acceptedOwnedVariants") or []
        if len(set(accepted)) != len(accepted):
            errors.append(f"{path}.acceptedOwnedVariants has duplicates")
        for candidate in accepted:
            if candidate not in catalog.group_of:
                errors.append(f"{path}.acceptedOwnedVariants unknown '{candidate}'")
            if candidate == variant:
                errors.append(f"{path}.acceptedOwnedVariants must differ from exact variant")
        if not isinstance(item.get("optional"), bool):
            errors.append(f"{path}.optional must be boolean")
        if status == "PUBLISHED" and item.get("optional") is False and variant is None and not accepted:
            errors.append(f"{path} required ingredient needs variant or acceptedOwnedVariants")
        for field_name in ("displayName", "rawText"):
            if not text(item.get(field_name)):
                errors.append(f"{path}.{field_name} must not be blank")
        for field_name in ("amount", "unit"):
            if item.get(field_name) is not None and not isinstance(item[field_name], str):
                errors.append(f"{path}.{field_name} must be a string or null")
    if not by_key:
        errors.append("ingredients must not be empty")

    roles: dict[str, int] = {}
    requirements = recipe.get("requirements")
    if not isinstance(requirements, list):
        errors.append("requirements must be an array")
        requirements = []
    for index, requirement in enumerate(requirements):
        options = requirement.get("options") or []
        if not options:
            errors.append(f"requirements[{index}].options must contain at least one option")
        for option in options:
            original = by_key.get(option.get("ingredient"))
            roles[option.get("ingredient")] = roles.get(option.get("ingredient"), 0) + 1
            if original is None:
                errors.append(f"requirements[{index}] unknown recipe ingredient '{option.get('ingredient')}'")
            elif original.get("optional"):
                errors.append(f"requirements[{index}] optional ingredient cannot participate")
            for substitute in option.get("substitutes") or []:
                roles[substitute] = roles.get(substitute, 0) + 1
                other = by_key.get(substitute)
                if other is None or other.get("optional") or substitute == option.get("ingredient"):
                    errors.append(f"requirements[{index}] substitute must be a different non-optional ingredient")
            for allowed in option.get("allowedVariants") or []:
                exact = (original or {}).get("variant")
                if (allowed not in catalog.group_of or exact is None or allowed == exact
                        or catalog.group_of[allowed] != catalog.group_of.get(exact)):
                    errors.append(f"requirements[{index}] allowed variant '{allowed}' must be another variant of the same ingredient")
    if status == "PUBLISHED":
        for key, item in by_key.items():
            if item.get("optional") is False and roles.get(key, 0) != 1:
                errors.append(f"ingredient '{key}' must have exactly one requirement role")

    steps = recipe.get("steps")
    if not steps or not all(text(step) for step in steps):
        errors.append("steps must be a non-empty list of non-blank strings")
    return errors
