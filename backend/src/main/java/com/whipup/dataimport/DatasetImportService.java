package com.whipup.dataimport;

import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.repository.IngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeIngredient;
import com.whipup.recipe.domain.RecipeStep;
import com.whipup.recipe.repository.RecipeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class DatasetImportService {

    private final IngredientRepository ingredientRepository;
    private final RecipeRepository recipeRepository;

    public DatasetImportService(
        IngredientRepository ingredientRepository,
        RecipeRepository recipeRepository
    ) {
        this.ingredientRepository = ingredientRepository;
        this.recipeRepository = recipeRepository;
    }

    @Transactional
    public ImportResult synchronize(Dataset dataset) {
        List<Ingredient> existingIngredients = ingredientRepository.findAll();
        Map<String, Ingredient> ingredientsByName = existingIngredients.stream()
            .collect(Collectors.toMap(Ingredient::getCanonicalName, Function.identity()));

        List<Ingredient> newIngredients = dataset.ingredientNames().stream()
            .filter(name -> !ingredientsByName.containsKey(name))
            .map(Ingredient::create)
            .toList();
        ingredientRepository.saveAllAndFlush(newIngredients);
        newIngredients.forEach(ingredient -> ingredientsByName.put(ingredient.getCanonicalName(), ingredient));

        List<Recipe> existingRecipes = recipeRepository.findAll();
        Map<String, Recipe> recipesByKey = existingRecipes.stream()
            .collect(Collectors.toMap(Recipe::getDatasetKey, Function.identity()));
        Set<String> datasetRecipeKeys = dataset.recipes().stream()
            .map(Dataset.RecipeData::key)
            .collect(Collectors.toCollection(HashSet::new));

        List<Recipe> obsoleteRecipes = existingRecipes.stream()
            .filter(recipe -> !datasetRecipeKeys.contains(recipe.getDatasetKey()))
            .toList();
        recipeRepository.deleteAll(obsoleteRecipes);

        Map<Recipe, Dataset.RecipeData> recipeDataByEntity = new HashMap<>();
        for (Dataset.RecipeData recipeData : dataset.recipes()) {
            Recipe recipe = recipesByKey.get(recipeData.key());
            if (recipe == null) {
                recipe = Recipe.createPublished(
                    recipeData.key(),
                    recipeData.name(),
                    recipeData.shortsReference()
                );
            } else {
                recipe.updatePublished(recipeData.name(), recipeData.shortsReference());
            }
            recipe.replaceIngredients(List.of());
            recipe.replaceSteps(List.of());
            recipeDataByEntity.put(recipe, recipeData);
        }

        List<Recipe> synchronizedRecipes = new ArrayList<>(recipeDataByEntity.keySet());
        recipeRepository.saveAllAndFlush(synchronizedRecipes);

        recipeDataByEntity.forEach((recipe, recipeData) -> {
            List<RecipeIngredient> recipeIngredients = new ArrayList<>();
            for (int index = 0; index < recipeData.ingredients().size(); index++) {
                Dataset.RecipeIngredientData ingredientData = recipeData.ingredients().get(index);
                Ingredient ingredient = ingredientsByName.get(ingredientData.canonicalIngredient());
                recipeIngredients.add(RecipeIngredient.create(
                    ingredient,
                    ingredientData.displayName(),
                    ingredientData.rawText(),
                    ingredientData.amount(),
                    ingredientData.unit(),
                    index + 1
                ));
            }

            List<RecipeStep> recipeSteps = new ArrayList<>();
            for (int index = 0; index < recipeData.steps().size(); index++) {
                recipeSteps.add(RecipeStep.create(index + 1, recipeData.steps().get(index)));
            }

            recipe.replaceIngredients(recipeIngredients);
            recipe.replaceSteps(recipeSteps);
        });
        recipeRepository.saveAllAndFlush(synchronizedRecipes);

        List<Ingredient> obsoleteIngredients = existingIngredients.stream()
            .filter(ingredient -> !dataset.ingredientNames().contains(ingredient.getCanonicalName()))
            .toList();
        ingredientRepository.deleteAll(obsoleteIngredients);
        ingredientRepository.flush();

        return new ImportResult(dataset.ingredientNames().size(), dataset.recipes().size());
    }

    public record ImportResult(int ingredientCount, int recipeCount) {
    }
}
