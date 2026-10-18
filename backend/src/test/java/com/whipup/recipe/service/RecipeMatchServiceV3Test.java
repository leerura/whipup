package com.whipup.recipe.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.IngredientVariantRelation;
import com.whipup.ingredient.repository.IngredientVariantRelationRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeIngredient;
import com.whipup.recipe.domain.RecipeRequirement;
import com.whipup.recipe.domain.RecipeRequirementOption;
import com.whipup.recipe.domain.RecipeRequirementSubstitute;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.service.RecipeMatchResult.IngredientMatchResult;
import com.whipup.recipe.service.RecipeMatchResult.MatchType;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class RecipeMatchServiceV3Test {

    private final IngredientVariantRelationRepository relations = mock(IngredientVariantRelationRepository.class);
    private final RecipeMatchService matcher = new RecipeMatchService(relations);

    @BeforeEach
    void noPreparationRelationsByDefault() {
        when(relations.findAllBySourceVariant_IdIn(anyCollection())).thenReturn(List.of());
    }

    @Test
    void acceptedOwnedCandidateMatchesDirectly() {
        IngredientVariant accepted = variant(2L, "진간장");
        Recipe recipe = recipe(sourceIngredient(List.of(accepted)), List.of());

        List<IngredientMatchResult> matches = matcher.match(recipe, List.of(accepted))
            .requirements().get(0).matches();

        assertEquals(1, matches.size());
        assertEquals(MatchType.DIRECT, matches.get(0).type());
        assertEquals(accepted, matches.get(0).ownedVariant());
    }

    @Test
    void acceptedOwnedCandidateCanMatchByOneStepPreparation() {
        IngredientVariant owned = variant(1L, "통마늘");
        IngredientVariant accepted = variant(2L, "다진 마늘");
        IngredientVariantRelation relation = mock(IngredientVariantRelation.class);
        when(relation.getSourceVariant()).thenReturn(owned);
        when(relation.getTargetVariant()).thenReturn(accepted);
        when(relations.findAllBySourceVariant_IdIn(anyCollection())).thenReturn(List.of(relation));
        Recipe recipe = recipe(sourceIngredient(List.of(accepted)), List.of());

        List<IngredientMatchResult> matches = matcher.match(recipe, List.of(owned))
            .requirements().get(0).matches();

        assertEquals(1, matches.size());
        assertEquals(MatchType.PREPARATION, matches.get(0).type());
        assertEquals(owned, matches.get(0).ownedVariant());
    }

    @Test
    void directAcceptedMatchTakesPriorityOverOwnedSubstitute() {
        IngredientVariant accepted = variant(1L, "양조간장");
        IngredientVariant substituteOwned = variant(2L, "굴소스");
        RecipeIngredient original = sourceIngredient(List.of(accepted));
        RecipeIngredient substitute = sourceIngredient(List.of(substituteOwned));
        Recipe recipe = recipe(original, List.of(RecipeRequirementSubstitute.create(substitute, 1)));

        List<IngredientMatchResult> matches = matcher.match(recipe, List.of(accepted, substituteOwned))
            .requirements().get(0).matches();

        assertEquals(1, matches.size());
        assertEquals(MatchType.DIRECT, matches.get(0).type());
        assertEquals(accepted, matches.get(0).ownedVariant());
    }

    @Test
    void acceptedSubstituteIsUsedWhenOriginalDoesNotMatch() {
        IngredientVariant acceptedOriginal = variant(1L, "진간장");
        IngredientVariant acceptedSubstitute = variant(2L, "굴소스");
        RecipeIngredient original = sourceIngredient(List.of(acceptedOriginal));
        RecipeIngredient substitute = sourceIngredient(List.of(acceptedSubstitute));
        Recipe recipe = recipe(original, List.of(RecipeRequirementSubstitute.create(substitute, 1)));

        List<IngredientMatchResult> matches = matcher.match(recipe, List.of(acceptedSubstitute))
            .requirements().get(0).matches();

        assertEquals(1, matches.size());
        assertEquals(MatchType.SUBSTITUTE, matches.get(0).type());
        assertEquals(acceptedSubstitute, matches.get(0).ownedVariant());
    }

    private Recipe recipe(RecipeIngredient original, List<RecipeRequirementSubstitute> substitutes) {
        Recipe recipe = Recipe.create("test-recipe", "테스트", RecipeStatus.PUBLISHED, "https://example.com");
        RecipeRequirementOption option = RecipeRequirementOption.create(original, 1, substitutes, List.of());
        recipe.replaceRequirements(List.of(RecipeRequirement.create(1, List.of(option))));
        return recipe;
    }

    private RecipeIngredient sourceIngredient(List<IngredientVariant> accepted) {
        return RecipeIngredient.create(null, accepted, "간장", "간장 1큰술", "1", "큰술", 1, false);
    }

    private IngredientVariant variant(Long id, String name) {
        IngredientVariant variant = mock(IngredientVariant.class);
        when(variant.getId()).thenReturn(id);
        when(variant.getName()).thenReturn(name);
        return variant;
    }
}
