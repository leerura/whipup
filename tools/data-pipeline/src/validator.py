import re
from pathlib import Path

from cache import write_json


IMMUTABLE_STAGE_ONE_FIELDS = ("displayName", "rawText", "amount", "unit")


def _text(value: object) -> str | None:
    if not isinstance(value, str):
        return None
    value = value.strip()
    return value or None


def _list(value: object) -> list | None:
    return value if isinstance(value, list) else None


def _master_variant_owners(ingredient_master: dict, errors: list[str]) -> dict[str, str]:
    owners: dict[str, str] = {}
    ingredient_keys: set[str] = set()

    for ingredient_index, ingredient in enumerate(ingredient_master.get("ingredients", [])):
        path = f"ingredients[{ingredient_index}]"
        if not isinstance(ingredient, dict):
            errors.append(f"{path} must be an object")
            continue

        ingredient_key = _text(ingredient.get("key"))
        if ingredient_key is None:
            errors.append(f"{path}.key is required")
            continue
        if ingredient_key in ingredient_keys:
            errors.append(f"duplicate Ingredient key: {ingredient_key}")
            continue
        ingredient_keys.add(ingredient_key)

        variants = _list(ingredient.get("variants"))
        if not variants:
            errors.append(f"{path}.variants must not be empty")
            continue

        base_count = 0
        ingredient_variant_keys: set[str] = set()
        for variant_index, variant in enumerate(variants):
            variant_path = f"{path}.variants[{variant_index}]"
            if not isinstance(variant, dict):
                errors.append(f"{variant_path} must be an object")
                continue

            variant_key = _text(variant.get("key"))
            if variant_key is None:
                errors.append(f"{variant_path}.key is required")
                continue
            if variant_key in owners:
                errors.append(f"duplicate Variant key: {variant_key}")
                continue

            owners[variant_key] = ingredient_key
            ingredient_variant_keys.add(variant_key)
            if variant.get("base") is True:
                base_count += 1

        if base_count != 1:
            errors.append(f"{path} must contain exactly one base Variant")

        relations = _list(ingredient.get("relations"))
        if relations is None:
            errors.append(f"{path}.relations must be an array")
            continue
        for relation_index, relation in enumerate(relations):
            relation_path = f"{path}.relations[{relation_index}]"
            if not isinstance(relation, dict):
                errors.append(f"{relation_path} must be an object")
                continue
            source = _text(relation.get("source"))
            target = _text(relation.get("target"))
            if source not in ingredient_variant_keys or target not in ingredient_variant_keys:
                errors.append(f"{relation_path} must reference Variants of the same Ingredient")
            elif source == target:
                errors.append(f"{relation_path}.source and target must differ")

    return owners


def _approved_by_source(approved_stage_one: dict, errors: list[str]) -> dict[str, dict]:
    approved: dict[str, dict] = {}
    ingredients = _list(approved_stage_one.get("ingredients"))
    if ingredients is None:
        errors.append("approved Stage 1 result must contain an ingredients array")
        return approved

    for index, ingredient in enumerate(ingredients):
        path = f"approved.ingredients[{index}]"
        if not isinstance(ingredient, dict):
            errors.append(f"{path} must be an object")
            continue
        source_id = _text(ingredient.get("sourceId"))
        if source_id is None:
            errors.append(f"{path}.sourceId is required")
            continue
        if source_id in approved:
            errors.append(f"duplicate approved sourceId: {source_id}")
            continue
        approved[source_id] = ingredient
    return approved


def validate_and_publish(
    approved_stage_one: dict,
    ingredient_master: dict,
    stage_two_result: dict,
    recipes_directory: Path,
) -> list[str]:
    errors: list[str] = []
    variant_owners = _master_variant_owners(ingredient_master, errors)
    approved = _approved_by_source(approved_stage_one, errors)

    recipe = stage_two_result.get("recipe")
    if not isinstance(recipe, dict):
        return [*errors, "Stage 2 result must contain a recipe object"]

    mapping_failures = _list(stage_two_result.get("mappingFailures"))
    if mapping_failures is None:
        errors.append("mappingFailures must be an array")
    elif mapping_failures:
        for index, failure in enumerate(mapping_failures):
            if isinstance(failure, dict):
                source_id = failure.get("sourceId", "unknown")
                code = failure.get("code", "unknown")
                errors.append(f"mapping failure for {source_id}: {code}")
            else:
                errors.append(f"mappingFailures[{index}] must be an object")

    key = _text(recipe.get("key"))
    name = _text(recipe.get("name"))
    shorts_reference = _text(recipe.get("shortsReference"))
    if key is None:
        errors.append("recipe.key is required")
    elif re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", key) is None:
        errors.append("recipe.key must be lowercase ASCII kebab-case")
    if name is None:
        errors.append("recipe.name is required")
    if shorts_reference is None:
        errors.append("recipe.shortsReference is required")

    ingredients = _list(recipe.get("ingredients"))
    if ingredients is None:
        errors.append("recipe.ingredients must be an array")
        ingredients = []

    local_ingredients: dict[str, dict] = {}
    structured_source_ids: set[str] = set()
    for index, ingredient in enumerate(ingredients):
        path = f"recipe.ingredients[{index}]"
        if not isinstance(ingredient, dict):
            errors.append(f"{path} must be an object")
            continue

        source_id = _text(ingredient.get("sourceId"))
        if source_id is None:
            errors.append(f"{path}.sourceId is required")
        elif source_id in structured_source_ids:
            errors.append(f"duplicate recipe sourceId: {source_id}")
        else:
            structured_source_ids.add(source_id)
            approved_ingredient = approved.get(source_id)
            if approved_ingredient is None:
                errors.append(f"{path}.sourceId is not an approved Stage 1 sourceId: {source_id}")
            else:
                for field in IMMUTABLE_STAGE_ONE_FIELDS:
                    if ingredient.get(field) != approved_ingredient.get(field):
                        errors.append(f"{path}.{field} differs from approved Stage 1 input")

        local_key = _text(ingredient.get("key"))
        if local_key is None:
            errors.append(f"{path}.key is required")
        elif local_key in local_ingredients:
            errors.append(f"duplicate recipe ingredient key: {local_key}")
        else:
            local_ingredients[local_key] = ingredient

        variant = _text(ingredient.get("variant"))
        if variant is None:
            errors.append(f"{path}.variant is required for a PUBLISHED Recipe")
        elif variant not in variant_owners:
            errors.append(f"{path}.variant is not in ingredients.json: {variant}")

        if not isinstance(ingredient.get("optional"), bool):
            errors.append(f"{path}.optional must be a boolean")

    if structured_source_ids != set(approved):
        missing = sorted(set(approved) - structured_source_ids)
        unexpected = sorted(structured_source_ids - set(approved))
        if missing:
            errors.append(f"missing approved sourceIds: {', '.join(missing)}")
        if unexpected:
            errors.append(f"unexpected sourceIds: {', '.join(unexpected)}")

    role_counts = {local_key: 0 for local_key in local_ingredients}
    requirements = _list(recipe.get("requirements"))
    if requirements is None:
        errors.append("recipe.requirements must be an array")
        requirements = []

    for requirement_index, requirement in enumerate(requirements):
        requirement_path = f"recipe.requirements[{requirement_index}]"
        if not isinstance(requirement, dict):
            errors.append(f"{requirement_path} must be an object")
            continue
        options = _list(requirement.get("options"))
        if not options:
            errors.append(f"{requirement_path}.options must contain at least one Option")
            continue

        for option_index, option in enumerate(options):
            option_path = f"{requirement_path}.options[{option_index}]"
            if not isinstance(option, dict):
                errors.append(f"{option_path} must be an object")
                continue
            original_key = _text(option.get("ingredient"))
            original = local_ingredients.get(original_key) if original_key else None
            if original is None:
                errors.append(f"{option_path}.ingredient must reference a Recipe Ingredient")
                continue
            if original.get("optional") is True:
                errors.append(f"{option_path}.ingredient must not reference an optional Ingredient")
            role_counts[original_key] += 1

            substitutes = _list(option.get("substitutes"))
            if substitutes is None:
                errors.append(f"{option_path}.substitutes must be an array")
                substitutes = []
            for substitute_index, substitute_key_value in enumerate(substitutes):
                substitute_path = f"{option_path}.substitutes[{substitute_index}]"
                substitute_key = _text(substitute_key_value)
                substitute = local_ingredients.get(substitute_key) if substitute_key else None
                if substitute is None:
                    errors.append(f"{substitute_path} must reference a Recipe Ingredient")
                    continue
                if substitute_key == original_key:
                    errors.append(f"{substitute_path} must differ from the original Option")
                if substitute.get("optional") is True:
                    errors.append(f"{substitute_path} must not reference an optional Ingredient")
                role_counts[substitute_key] += 1

            allowed_variants = _list(option.get("allowedVariants"))
            if allowed_variants is None:
                errors.append(f"{option_path}.allowedVariants must be an array")
                continue
            original_variant = _text(original.get("variant"))
            original_owner = variant_owners.get(original_variant)
            for allowed_index, allowed_variant_value in enumerate(allowed_variants):
                allowed_path = f"{option_path}.allowedVariants[{allowed_index}]"
                allowed_variant = _text(allowed_variant_value)
                allowed_owner = variant_owners.get(allowed_variant)
                if allowed_owner is None:
                    errors.append(f"{allowed_path} is not in ingredients.json")
                elif allowed_variant == original_variant or allowed_owner != original_owner:
                    errors.append(
                        f"{allowed_path} must be a different Variant of the original Ingredient"
                    )

    for local_key, ingredient in local_ingredients.items():
        if ingredient.get("optional") is False and role_counts[local_key] != 1:
            errors.append(
                f"recipe ingredient {local_key} must participate exactly once as an Option or Substitute"
            )

    steps = _list(recipe.get("steps"))
    if not steps:
        errors.append("recipe.steps must contain at least one step")
    elif any(_text(step) is None for step in steps):
        errors.append("recipe.steps must not contain blank steps")

    if errors:
        return errors

    final_recipe = {
        "key": key,
        "name": name,
        "status": "PUBLISHED",
        "shortsReference": shorts_reference,
        "ingredients": [
            {
                "key": ingredient["key"],
                "variant": ingredient["variant"],
                "displayName": ingredient["displayName"],
                "rawText": ingredient["rawText"],
                "amount": ingredient["amount"],
                "unit": ingredient["unit"],
                "optional": ingredient["optional"],
            }
            for ingredient in ingredients
        ],
        "requirements": requirements,
        "steps": steps,
    }
    write_json(recipes_directory / f"{key}.json", final_recipe)
    return []
