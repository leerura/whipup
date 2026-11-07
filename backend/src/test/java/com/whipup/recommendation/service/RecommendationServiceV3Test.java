package com.whipup.recommendation.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.whipup.generated.model.MissingRequirementResult;
import com.whipup.generated.model.RecommendationMode;
import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.repository.IngredientVariantRelationRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeIngredient;
import com.whipup.recipe.domain.RecipeRequirement;
import com.whipup.recipe.domain.RecipeRequirementOption;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.repository.RecipeRepository;
import com.whipup.recipe.service.RecipeMatchService;
import java.util.List;
import org.junit.jupiter.api.Test;

class RecommendationServiceV3Test {

    private final UserIngredientRepository userIngredientRepository = mock(UserIngredientRepository.class);
    private final RecipeRepository recipeRepository = mock(RecipeRepository.class);
    private final IngredientVariantRelationRepository relationRepository = mock(IngredientVariantRelationRepository.class);

    @Test
    void exactSourceVariantUsesSelectableItemNameForMissingOption() {
        IngredientVariant requiredVariant = variant(2L, "닭다리살");
        String requiredName = missingRequiredName(
            "순살 닭다리 정육",
            requiredVariant
        );

        assertEquals("닭다리살", requiredName);
    }

    @Test
    void genericSourceKeepsItsDisplayNameForMissingOption() {
        String requiredName = missingRequiredName("간장", null);

        assertEquals("간장", requiredName);
    }

    private String missingRequiredName(
        String sourceDisplayName,
        IngredientVariant requiredVariant
    ) {
        IngredientVariant ownedVariant = variant(1L, "밥");
        UserIngredient ownedIngredient = mock(UserIngredient.class);
        when(ownedIngredient.getIngredientVariant()).thenReturn(ownedVariant);
        when(userIngredientRepository.findAllByUser_IdOrderByIngredientVariant_NameAsc(7L))
            .thenReturn(List.of(ownedIngredient));
        when(relationRepository.findAllBySourceVariant_IdIn(anyCollection()))
            .thenReturn(List.of());

        RecipeIngredient source = RecipeIngredient.create(
            requiredVariant,
            List.of(),
            sourceDisplayName,
            sourceDisplayName,
            null,
            null,
            1,
            false
        );
        RecipeRequirementOption option = RecipeRequirementOption.create(
            source,
            1,
            List.of(),
            List.of()
        );
        RecipeRequirement requirement = RecipeRequirement.create(1, List.of(option));
        Recipe recipe = mock(Recipe.class);
        when(recipe.getId()).thenReturn(100L);
        when(recipe.getName()).thenReturn("테스트 레시피");
        when(recipe.getShortsReference()).thenReturn("https://youtube.com/shorts/test");
        when(recipe.getRequirements()).thenReturn(List.of(requirement));
        when(recipeRepository.findAllByStatusOrderByIdAsc(RecipeStatus.PUBLISHED))
            .thenReturn(List.of(recipe));

        RecommendationService service = new RecommendationService(
            recipeRepository,
            userIngredientRepository,
            new RecipeMatchService(relationRepository)
        );

        MissingRequirementResult missing = (MissingRequirementResult) service
            .getRecipeRecommendations(7L, RecommendationMode.MISSING_INGREDIENTS)
            .getItems()
            .get(0)
            .getRequirementResults()
            .get(0);

        return missing.getMissingOptions().get(0).getRequiredName();
    }

    private IngredientVariant variant(Long id, String name) {
        IngredientVariant variant = mock(IngredientVariant.class);
        when(variant.getId()).thenReturn(id);
        when(variant.getName()).thenReturn(name);
        return variant;
    }
}
