package com.whipup.recipe.service;

import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.IngredientVariantRelation;
import com.whipup.ingredient.repository.IngredientVariantRelationRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeRequirement;
import com.whipup.recipe.domain.RecipeRequirementOption;
import com.whipup.recipe.domain.RecipeRequirementSubstitute;
import com.whipup.recipe.service.RecipeMatchResult.IngredientMatchResult;
import com.whipup.recipe.service.RecipeMatchResult.MatchType;
import com.whipup.recipe.service.RecipeMatchResult.RequirementResult;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Service;

@Service
public class RecipeMatchService {

    private final IngredientVariantRelationRepository relationRepository;

    public RecipeMatchService(
        IngredientVariantRelationRepository relationRepository
    ) {
        this.relationRepository = relationRepository;
    }

    public RecipeMatchResult match(
        Recipe recipe,
        List<IngredientVariant> ownedVariants
    ) {
        return match(recipe, createMatchContext(ownedVariants));
    }

    public List<MatchedRecipe> matchAll(
        List<Recipe> recipes,
        List<IngredientVariant> ownedVariants
    ) {
        MatchContext context = createMatchContext(ownedVariants);

        return recipes.stream()
            .map(recipe -> new MatchedRecipe(recipe, match(recipe, context)))
            .toList();
    }

    private MatchContext createMatchContext(List<IngredientVariant> ownedVariants) {
        List<IngredientVariant> sortedOwnedVariants = ownedVariants.stream()
            .sorted(Comparator.comparing(IngredientVariant::getName)
                .thenComparing(IngredientVariant::getId))
            .toList();

        Map<Long, IngredientVariant> ownedVariantsById = new HashMap<>();
        sortedOwnedVariants.forEach(variant ->
            ownedVariantsById.put(variant.getId(), variant)
        );

        Map<Long, Set<Long>> preparationTargetsBySource =
            findPreparationTargets(ownedVariantsById.keySet());

        return new MatchContext(
            sortedOwnedVariants,
            ownedVariantsById,
            preparationTargetsBySource
        );
    }

    private RecipeMatchResult match(Recipe recipe, MatchContext context) {
        List<RequirementResult> requirementResults = recipe.getRequirements()
            .stream()
            .sorted(Comparator.comparingInt(RecipeRequirement::getDisplayOrder))
            .map(requirement -> new RequirementResult(
                requirement,
                matchRequirement(
                    requirement,
                    context.ownedVariants(),
                    context.ownedVariantsById(),
                    context.preparationTargetsBySource()
                )
            ))
            .toList();

        return new RecipeMatchResult(requirementResults);
    }

    private Map<Long, Set<Long>> findPreparationTargets(Set<Long> ownedVariantIds) {
        Map<Long, Set<Long>> targetsBySource = new HashMap<>();
        if (ownedVariantIds.isEmpty()) {
            return targetsBySource;
        }

        relationRepository.findAllBySourceVariant_IdIn(ownedVariantIds)
            .forEach(relation -> targetsBySource
                .computeIfAbsent(
                    relation.getSourceVariant().getId(),
                    ignored -> new HashSet<>()
                )
                .add(relation.getTargetVariant().getId()));

        return targetsBySource;
    }

    private List<IngredientMatchResult> matchRequirement(
        RecipeRequirement requirement,
        List<IngredientVariant> ownedVariants,
        Map<Long, IngredientVariant> ownedVariantsById,
        Map<Long, Set<Long>> preparationTargetsBySource
    ) {
        return requirement.getOptions()
            .stream()
            .sorted(Comparator.comparingInt(RecipeRequirementOption::getDisplayOrder))
            .flatMap(option -> matchOption(
                option,
                ownedVariants,
                ownedVariantsById,
                preparationTargetsBySource
            ).stream())
            .toList();
    }

    private List<IngredientMatchResult> matchOption(
        RecipeRequirementOption option,
        List<IngredientVariant> ownedVariants,
        Map<Long, IngredientVariant> ownedVariantsById,
        Map<Long, Set<Long>> preparationTargetsBySource
    ) {
        Set<Long> acceptedVariantIds = new HashSet<>();
        acceptedVariantIds.add(option.getIngredient().getIngredientVariant().getId());
        option.getAllowedVariants()
            .stream()
            .map(IngredientVariant::getId)
            .forEach(acceptedVariantIds::add);

        List<IngredientMatchResult> directMatches = ownedVariants.stream()
            .filter(owned -> acceptedVariantIds.contains(owned.getId()))
            .map(owned -> new IngredientMatchResult(
                MatchType.DIRECT,
                option,
                owned
            ))
            .toList();
        if (!directMatches.isEmpty()) {
            return directMatches;
        }

        List<IngredientMatchResult> preparationMatches = ownedVariants.stream()
            .filter(owned -> preparationTargetsBySource
                .getOrDefault(owned.getId(), Set.of())
                .stream()
                .anyMatch(acceptedVariantIds::contains))
            .map(owned -> new IngredientMatchResult(
                MatchType.PREPARATION,
                option,
                owned
            ))
            .toList();
        if (!preparationMatches.isEmpty()) {
            return preparationMatches;
        }

        List<IngredientMatchResult> substituteMatches = new ArrayList<>();
        option.getSubstitutes()
            .stream()
            .sorted(Comparator.comparingInt(
                RecipeRequirementSubstitute::getDisplayOrder
            ))
            .map(RecipeRequirementSubstitute::getIngredient)
            .map(ingredient -> ownedVariantsById.get(
                ingredient.getIngredientVariant().getId()
            ))
            .filter(owned -> owned != null)
            .map(owned -> new IngredientMatchResult(
                MatchType.SUBSTITUTE,
                option,
                owned
            ))
            .forEach(substituteMatches::add);

        return substituteMatches;
    }

    public record MatchedRecipe(Recipe recipe, RecipeMatchResult matchResult) {
    }

    private record MatchContext(
        List<IngredientVariant> ownedVariants,
        Map<Long, IngredientVariant> ownedVariantsById,
        Map<Long, Set<Long>> preparationTargetsBySource
    ) {
    }
}
