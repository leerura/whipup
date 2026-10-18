package com.whipup.dataimport;

import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.whipup.ingredient.repository.IngredientRepository;
import com.whipup.ingredient.repository.IngredientVariantRelationRepository;
import com.whipup.ingredient.repository.IngredientVariantRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.repository.RecipeRepository;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;

class DatasetImportServiceV3Test {

    @Test
    void clearsAndFlushesExistingRecipeChildrenBeforeSavingReplacementRows() {
        IngredientRepository ingredients = mock(IngredientRepository.class);
        IngredientVariantRepository variants = mock(IngredientVariantRepository.class);
        IngredientVariantRelationRepository relations = mock(IngredientVariantRelationRepository.class);
        UserIngredientRepository userIngredients = mock(UserIngredientRepository.class);
        RecipeRepository recipes = mock(RecipeRepository.class);
        Recipe existingRecipe = mock(Recipe.class);

        when(ingredients.findAll()).thenReturn(List.of());
        when(variants.findAll()).thenReturn(List.of());
        when(recipes.findAll()).thenReturn(List.of(existingRecipe));
        when(existingRecipe.getDatasetKey()).thenReturn("soy-sauce-recipe");

        DatasetImportService service = new DatasetImportService(
            ingredients, variants, relations, userIngredients, recipes
        );
        service.synchronize(dataset());

        InOrder order = inOrder(existingRecipe, recipes);
        order.verify(existingRecipe).update("간장 요리", com.whipup.recipe.domain.RecipeStatus.PUBLISHED,
            "https://example.com/video");
        order.verify(existingRecipe).replaceRequirements(List.of());
        order.verify(recipes).flush();
        order.verify(existingRecipe).replaceIngredients(List.of());
        order.verify(existingRecipe).replaceSteps(List.of());
        order.verify(recipes).flush();
        order.verify(existingRecipe).replaceIngredients(argThat(items -> items.size() == 1
            && items.get(0).getDisplayOrder() == 1));
        order.verify(existingRecipe).replaceSteps(argThat(steps -> steps.size() == 1
            && steps.get(0).getStepOrder() == 1));
        order.verify(existingRecipe).replaceRequirements(argThat(requirements -> requirements.size() == 1
            && requirements.get(0).getDisplayOrder() == 1));
        order.verify(recipes).save(existingRecipe);
    }

    private Dataset dataset() {
        Dataset.IngredientData ingredient = new Dataset.IngredientData(
            "soy-sauce",
            "간장",
            List.of(new Dataset.VariantData("dark-soy-sauce", "진간장", List.of())),
            List.of()
        );
        Dataset.RecipeIngredientData recipeIngredient = new Dataset.RecipeIngredientData(
            "soy-sauce", "dark-soy-sauce", List.of(), "진간장", "진간장 1큰술", "1", "큰술", false
        );
        Dataset.RequirementOptionData option = new Dataset.RequirementOptionData(
            "soy-sauce", List.of(), List.of()
        );
        Dataset.RecipeData recipe = new Dataset.RecipeData(
            "soy-sauce-recipe",
            "간장 요리",
            "PUBLISHED",
            "https://example.com/video",
            List.of(recipeIngredient),
            List.of(new Dataset.RequirementData(List.of(option))),
            List.of("볶는다.")
        );
        return new Dataset(List.of(ingredient), List.of(recipe));
    }
}
