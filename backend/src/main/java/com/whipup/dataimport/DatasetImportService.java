package com.whipup.dataimport;

import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.IngredientVariantRelation;
import com.whipup.ingredient.repository.IngredientRepository;
import com.whipup.ingredient.repository.IngredientVariantRelationRepository;
import com.whipup.ingredient.repository.IngredientVariantRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeIngredient;
import com.whipup.recipe.domain.RecipeRequirement;
import com.whipup.recipe.domain.RecipeRequirementOption;
import com.whipup.recipe.domain.RecipeRequirementSubstitute;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.domain.RecipeStep;
import com.whipup.recipe.repository.RecipeRepository;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DatasetImportService {
    private final IngredientRepository ingredients;
    private final IngredientVariantRepository variants;
    private final IngredientVariantRelationRepository relations;
    private final UserIngredientRepository userIngredients;
    private final RecipeRepository recipes;

    public DatasetImportService(IngredientRepository ingredients, IngredientVariantRepository variants,
            IngredientVariantRelationRepository relations, UserIngredientRepository userIngredients,
            RecipeRepository recipes) {
        this.ingredients = ingredients;
        this.variants = variants;
        this.relations = relations;
        this.userIngredients = userIngredients;
        this.recipes = recipes;
    }

    @Transactional
    public ImportResult synchronize(Dataset dataset) {
        List<Ingredient> existingIngredients = ingredients.findAll();
        List<IngredientVariant> existingVariants = variants.findAll();
        Set<String> targetVariantKeys = dataset.ingredients().stream().flatMap(i -> i.variants().stream())
            .map(Dataset.VariantData::key).collect(Collectors.toSet());
        List<IngredientVariant> deletedVariants = existingVariants.stream()
            .filter(v -> !targetVariantKeys.contains(v.getKey())).toList();
        if (!deletedVariants.isEmpty() && userIngredients.existsByIngredientVariant_IdIn(
                deletedVariants.stream().map(IngredientVariant::getId).toList())) {
            throw new DatasetValidationException(List.of(new DatasetValidationError(
                "MASTER_DELETE_BLOCKED", "database", "ingredient_variant",
                "a removed variant is referenced by user ingredients"
            )));
        }

        Map<String, Ingredient> ingredientByKey = existingIngredients.stream()
            .collect(Collectors.toMap(Ingredient::getKey, Function.identity()));
        for (Dataset.IngredientData data : dataset.ingredients()) {
            Ingredient ingredient = ingredientByKey.get(data.key());
            if (ingredient == null) {
                ingredient = Ingredient.create(data.key(), data.name());
                ingredientByKey.put(data.key(), ingredient);
            } else ingredient.update(data.name());
        }
        ingredients.saveAllAndFlush(ingredientByKey.values());

        Map<String, IngredientVariant> variantByKey = existingVariants.stream()
            .collect(Collectors.toMap(IngredientVariant::getKey, Function.identity()));
        for (Dataset.IngredientData data : dataset.ingredients()) {
            Ingredient ingredient = ingredientByKey.get(data.key());
            for (Dataset.VariantData variantData : data.variants()) {
                IngredientVariant variant = variantByKey.get(variantData.key());
                if (variant == null) {
                    variant = IngredientVariant.create(variantData.key(), ingredient, variantData.name(), variantData.base());
                    variantByKey.put(variantData.key(), variant);
                } else variant.update(ingredient, variantData.name(), variantData.base());
            }
        }
        variants.saveAllAndFlush(variantByKey.values());
        syncRecipes(dataset, variantByKey);

        relations.deleteAll();
        relations.saveAll(dataset.ingredients().stream().flatMap(i -> i.relations().stream().map(r ->
            IngredientVariantRelation.create(variantByKey.get(r.source()), variantByKey.get(r.target()))
        )).toList());
        variants.deleteAll(deletedVariants);
        ingredients.deleteAll(existingIngredients.stream().filter(i -> dataset.ingredients().stream()
            .noneMatch(data -> data.key().equals(i.getKey()))).toList());
        return new ImportResult(dataset.ingredients().size(), targetVariantKeys.size(), dataset.recipes().size());
    }

    private void syncRecipes(Dataset dataset, Map<String, IngredientVariant> variantsByKey) {
        List<Recipe> existing = recipes.findAll();
        Map<String, Recipe> byKey = existing.stream().collect(Collectors.toMap(Recipe::getDatasetKey, Function.identity()));
        Set<String> targetKeys = dataset.recipes().stream().map(Dataset.RecipeData::key).collect(Collectors.toSet());
        recipes.deleteAll(existing.stream().filter(recipe -> !targetKeys.contains(recipe.getDatasetKey())).toList());
        for (Dataset.RecipeData data : dataset.recipes()) {
            Recipe recipe = byKey.get(data.key());
            RecipeStatus status = RecipeStatus.valueOf(data.status());
            if (recipe == null) recipe = Recipe.create(data.key(), data.name(), status, data.shortsReference());
            else recipe.update(data.name(), status, data.shortsReference());
            Map<String, RecipeIngredient> local = new HashMap<>();
            List<RecipeIngredient> items = new ArrayList<>();
            for (int i = 0; i < data.ingredients().size(); i++) {
                Dataset.RecipeIngredientData item = data.ingredients().get(i);
                RecipeIngredient entity = RecipeIngredient.create(variantsByKey.get(item.variant()), item.displayName(),
                    item.rawText(), item.amount(), item.unit(), i + 1, item.optional());
                items.add(entity); local.put(item.key(), entity);
            }
            recipe.replaceIngredients(items);
            List<RecipeStep> steps = new ArrayList<>();
            for (int i = 0; i < data.steps().size(); i++) steps.add(RecipeStep.create(i + 1, data.steps().get(i)));
            recipe.replaceSteps(steps);
            List<RecipeRequirement> requirements = new ArrayList<>();
            for (int i = 0; i < data.requirements().size(); i++) {
                Dataset.RequirementData requirement = data.requirements().get(i);
                List<RecipeRequirementOption> options = new ArrayList<>();
                for (int j = 0; j < requirement.options().size(); j++) {
                    Dataset.RequirementOptionData option = requirement.options().get(j);
                    List<RecipeRequirementSubstitute> substitutes = new ArrayList<>();
                    for (int k = 0; k < option.substitutes().size(); k++)
                        substitutes.add(RecipeRequirementSubstitute.create(local.get(option.substitutes().get(k)), k + 1));
                    options.add(RecipeRequirementOption.create(local.get(option.ingredient()), j + 1, substitutes,
                        option.allowedVariants().stream().map(variantsByKey::get).toList()));
                }
                requirements.add(RecipeRequirement.create(i + 1, options));
            }
            recipe.replaceRequirements(requirements);
            recipes.save(recipe);
        }
        recipes.flush();
    }

    public record ImportResult(int ingredientCount, int variantCount, int recipeCount) { }
}
