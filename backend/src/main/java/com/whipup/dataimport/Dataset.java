package com.whipup.dataimport;

import java.util.List;

public record Dataset(List<IngredientData> ingredients, List<RecipeData> recipes) {
    public Dataset {
        ingredients = List.copyOf(ingredients);
        recipes = List.copyOf(recipes);
    }

    public record IngredientData(String key, String name, List<VariantData> variants, List<RelationData> relations) {
        public IngredientData {
            variants = List.copyOf(variants);
            relations = List.copyOf(relations);
        }
    }

    public record VariantData(String key, String name, boolean base, List<String> aliases) {
        public VariantData {
            aliases = List.copyOf(aliases);
        }
    }

    public record RelationData(String source, String target) { }

    public record RecipeData(
        String key,
        String name,
        String status,
        String shortsReference,
        List<RecipeIngredientData> ingredients,
        List<RequirementData> requirements,
        List<String> steps
    ) {
        public RecipeData {
            ingredients = List.copyOf(ingredients);
            requirements = List.copyOf(requirements);
            steps = List.copyOf(steps);
        }
    }

    public record RecipeIngredientData(
        String key, String variant, String displayName, String rawText, String amount, String unit, boolean optional
    ) { }

    public record RequirementData(List<RequirementOptionData> options) {
        public RequirementData {
            options = List.copyOf(options);
        }
    }

    public record RequirementOptionData(String ingredient, List<String> substitutes, List<String> allowedVariants) {
        public RequirementOptionData {
            substitutes = List.copyOf(substitutes);
            allowedVariants = List.copyOf(allowedVariants);
        }
    }
}
