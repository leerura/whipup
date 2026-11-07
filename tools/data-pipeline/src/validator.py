"""Small structural checks for V3 Gemini drafts; never performs semantic review."""

import re


SOURCE_FIELDS = ("displayName", "rawText", "amount", "unit")


def _is_nonempty_string(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def validate_source_extraction(extraction: dict) -> list[str]:
    """Check only the shape Codex needs to apply Gemini's source facts."""
    errors: list[str] = []
    if not _is_nonempty_string(extraction.get("title")):
        errors.append("title is required")
    ingredients = extraction.get("ingredients")
    if not isinstance(ingredients, list):
        errors.append("ingredients must be an array")
        ingredients = []
    for index, ingredient in enumerate(ingredients):
        path = f"ingredients[{index}]"
        if not isinstance(ingredient, dict):
            errors.append(f"{path} must be an object")
            continue
        if not _is_nonempty_string(ingredient.get("sourceId")):
            errors.append(f"{path}.sourceId is required")
        if not _is_nonempty_string(ingredient.get("rawText")):
            errors.append(f"{path}.rawText is required")
        if not _is_nonempty_string(ingredient.get("displayName")):
            errors.append(f"{path}.displayName is required")
        if ingredient.get("amount") is not None and not isinstance(ingredient.get("amount"), str):
            errors.append(f"{path}.amount must be a string or null")
        if ingredient.get("unit") is not None and not isinstance(ingredient.get("unit"), str):
            errors.append(f"{path}.unit must be a string or null")
        if not isinstance(ingredient.get("optional"), bool):
            errors.append(f"{path}.optional must be a boolean")
        if not isinstance(ingredient.get("evidences"), list):
            errors.append(f"{path}.evidences must be an array")

    steps = extraction.get("steps")
    if not isinstance(steps, list) or not steps or any(
        not isinstance(step, dict) or not _is_nonempty_string(step.get("text"))
        for step in steps
    ):
        errors.append("steps must be an array of objects with non-empty text")
    if not isinstance(extraction.get("unresolved", []), list):
        errors.append("unresolved must be an array")
    return errors


def _catalog_keys(catalog: dict, additions: dict) -> tuple[set[str], set[str]]:
    groups: set[str] = set()
    variants: set[str] = set()
    all_catalogs = (catalog, additions)
    for source in all_catalogs:
        ingredients = source.get("ingredients", []) if isinstance(source, dict) else []
        if not isinstance(ingredients, list):
            continue
        for ingredient in ingredients:
            if not isinstance(ingredient, dict):
                continue
            if _is_nonempty_string(ingredient.get("key")):
                groups.add(ingredient["key"])
            variants_value = ingredient.get("variants", [])
            if not isinstance(variants_value, list):
                continue
            for variant in variants_value:
                if isinstance(variant, dict) and _is_nonempty_string(variant.get("key")):
                    variants.add(variant["key"])
    return groups, variants


def validate_draft(stage_one: dict, stage_two: dict, catalog: dict) -> list[str]:
    errors: list[str] = []
    additions = stage_two.get("catalogAdditions", {"ingredients": []})
    if not isinstance(additions, dict) or not isinstance(additions.get("ingredients", []), list):
        errors.append("catalogAdditions.ingredients must be an array")
        additions = {"ingredients": []}
    recipe = stage_two.get("recipe")
    if not isinstance(recipe, dict):
        return ["Stage 2 result must contain a recipe object"]
    if not _is_nonempty_string(recipe.get("key")):
        errors.append("recipe.key is required")
    elif re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", recipe["key"]) is None:
        errors.append("recipe.key must be lowercase ASCII kebab-case")
    if not _is_nonempty_string(recipe.get("name")):
        errors.append("recipe.name is required")
    if recipe.get("status") != "DRAFT":
        errors.append("Gemini draft recipe.status must be DRAFT")
    if not _is_nonempty_string(recipe.get("shortsReference")):
        errors.append("recipe.shortsReference is required")

    stage_one_ingredients = stage_one.get("ingredients")
    recipe_ingredients = recipe.get("ingredients")
    if not isinstance(stage_one_ingredients, list):
        errors.append("Stage 1 result must contain an ingredients array")
        stage_one_ingredients = []
    if not isinstance(recipe_ingredients, list):
        errors.append("recipe.ingredients must be an array")
        recipe_ingredients = []

    source_map: dict[str, dict] = {}
    for index, ingredient in enumerate(stage_one_ingredients):
        if not isinstance(ingredient, dict) or not _is_nonempty_string(ingredient.get("sourceId")):
            errors.append(f"Stage 1 ingredients[{index}].sourceId is required")
            continue
        source_id = ingredient["sourceId"]
        if source_id in source_map:
            errors.append(f"duplicate Stage 1 sourceId: {source_id}")
        source_map[source_id] = ingredient

    source_ids: set[str] = set()
    recipe_keys: set[str] = set()
    _, variants = _catalog_keys(catalog, additions)
    optional_by_key: dict[str, bool] = {}
    for index, ingredient in enumerate(recipe_ingredients):
        path = f"recipe.ingredients[{index}]"
        if not isinstance(ingredient, dict):
            errors.append(f"{path} must be an object")
            continue
        source_id = ingredient.get("sourceId")
        if not _is_nonempty_string(source_id):
            errors.append(f"{path}.sourceId is required")
        elif source_id in source_ids:
            errors.append(f"duplicate recipe sourceId: {source_id}")
        else:
            source_ids.add(source_id)
            source = source_map.get(source_id)
            if source is None:
                errors.append(f"{path}.sourceId is not present in Stage 1")
            else:
                for field in SOURCE_FIELDS:
                    if ingredient.get(field) != source.get(field):
                        errors.append(f"{path}.{field} differs from Stage 1 source")
        key = ingredient.get("key")
        if not _is_nonempty_string(key):
            errors.append(f"{path}.key is required")
        elif key in recipe_keys:
            errors.append(f"duplicate recipe ingredient key: {key}")
        else:
            recipe_keys.add(key)
        if not isinstance(ingredient.get("optional"), bool):
            errors.append(f"{path}.optional must be a boolean")
        elif _is_nonempty_string(key):
            optional_by_key[key] = ingredient["optional"]
        variant = ingredient.get("variant")
        if variant is not None and (not isinstance(variant, str) or variant not in variants):
            errors.append(f"{path}.variant is neither in the catalog nor proposed additions")
        accepted = ingredient.get("acceptedOwnedVariants", [])
        if not isinstance(accepted, list) or any(not isinstance(value, str) for value in accepted):
            errors.append(f"{path}.acceptedOwnedVariants must be an array of strings")
        elif any(value not in variants for value in accepted):
            errors.append(f"{path}.acceptedOwnedVariants contains a key absent from catalog/additions")
        elif len(accepted) != len(set(accepted)):
            errors.append(f"{path}.acceptedOwnedVariants must not contain duplicates")
        if isinstance(accepted, list) and ingredient.get("variant") in accepted:
            errors.append(f"{path}.acceptedOwnedVariants must not repeat variant")

    if source_ids != set(source_map):
        errors.append("recipe.ingredients must contain each Stage 1 sourceId exactly once")

    requirements = recipe.get("requirements")
    if not isinstance(requirements, list):
        errors.append("recipe.requirements must be an array")
        requirements = []
    role_counts = {key: 0 for key in recipe_keys}
    for req_index, requirement in enumerate(requirements):
        options = requirement.get("options") if isinstance(requirement, dict) else None
        if not isinstance(options, list) or not options:
            errors.append(f"recipe.requirements[{req_index}].options must be a non-empty array")
            continue
        for option_index, option in enumerate(options):
            if not isinstance(option, dict):
                errors.append(f"recipe.requirements[{req_index}].options[{option_index}] must be an object")
                continue
            original = option.get("ingredient")
            if not isinstance(original, str) or original not in recipe_keys:
                errors.append(f"recipe.requirements[{req_index}].options[{option_index}].ingredient is unknown")
            elif optional_by_key.get(original, False):
                errors.append(f"recipe.requirements[{req_index}].options[{option_index}].ingredient must not be optional")
            else:
                role_counts[original] += 1
            substitutes = option.get("substitutes")
            if not isinstance(substitutes, list):
                errors.append(f"recipe.requirements[{req_index}].options[{option_index}].substitutes must be an array")
            else:
                for substitute in substitutes:
                    if not isinstance(substitute, str) or substitute not in recipe_keys:
                        errors.append(f"recipe.requirements[{req_index}].options[{option_index}] has unknown substitute")
                    elif optional_by_key.get(substitute, False):
                        errors.append(f"recipe.requirements[{req_index}].options[{option_index}] substitute must not be optional")
                    else:
                        role_counts[substitute] += 1
            allowed = option.get("allowedVariants")
            if not isinstance(allowed, list):
                errors.append(f"recipe.requirements[{req_index}].options[{option_index}].allowedVariants must be an array")
            elif any(not isinstance(value, str) or value not in variants for value in allowed):
                errors.append(f"recipe.requirements[{req_index}].options[{option_index}].allowedVariants contains an unknown Variant")

    for key, optional in optional_by_key.items():
        if not optional and role_counts[key] != 1:
            errors.append(f"required recipe ingredient {key} must participate exactly once in a requirement")
    steps = recipe.get("steps")
    if not isinstance(steps, list) or not steps or any(not _is_nonempty_string(step) for step in steps):
        errors.append("recipe.steps must contain non-empty strings")
    failures = stage_two.get("mappingFailures", [])
    if not isinstance(failures, list):
        errors.append("mappingFailures must be an array")
    return errors
