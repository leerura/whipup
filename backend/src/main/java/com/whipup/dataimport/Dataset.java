package com.whipup.dataimport;

import java.util.List;
import java.util.Set;

public record Dataset(
    Set<String> ingredientNames,
    List<RecipeData> recipes
) {

    public Dataset {
        ingredientNames = Set.copyOf(ingredientNames);
        recipes = List.copyOf(recipes);
    }

    public record RecipeData(
        String key,
        String name,
        String shortsReference,
        List<RecipeIngredientData> ingredients,
        List<String> steps
    ) {

        public RecipeData {
            ingredients = List.copyOf(ingredients);
            steps = List.copyOf(steps);
        }
    }

    public record RecipeIngredientData(
        String canonicalIngredient,
        String displayName,
        String rawText,
        String amount,
        String unit
    ) {
    }
}
