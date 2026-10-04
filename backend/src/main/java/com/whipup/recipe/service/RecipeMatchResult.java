package com.whipup.recipe.service;

import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.recipe.domain.RecipeRequirement;
import com.whipup.recipe.domain.RecipeRequirementOption;
import java.util.List;

public record RecipeMatchResult(List<RequirementResult> requirements) {

    public int missingCount() {
        return (int) requirements.stream()
            .filter(result -> !result.satisfied())
            .count();
    }

    public record RequirementResult(
        RecipeRequirement requirement,
        List<IngredientMatchResult> matches
    ) {
        public boolean satisfied() {
            return !matches.isEmpty();
        }
    }

    public record IngredientMatchResult(
        MatchType type,
        RecipeRequirementOption option,
        IngredientVariant ownedVariant
    ) {
    }

    public enum MatchType {
        DIRECT,
        PREPARATION,
        SUBSTITUTE
    }
}
