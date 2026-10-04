package com.whipup.dataimport;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Stream;
import org.springframework.stereotype.Component;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

@Component
public class DatasetLoader {

    private static final Pattern KEBAB_KEY = Pattern.compile("[a-z0-9]+(?:-[a-z0-9]+)*");
    private final ObjectMapper objectMapper;

    public DatasetLoader(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public Dataset load(Path dataDirectory) {
        List<DatasetValidationError> errors = new ArrayList<>();
        Path ingredientFile = dataDirectory.resolve("ingredients.json");
        List<Dataset.IngredientData> ingredients = loadIngredients(ingredientFile, errors);
        MasterIndex master = indexMaster(ingredients);
        List<Dataset.RecipeData> recipes = loadRecipes(dataDirectory.resolve("recipes"), master, errors);
        if (!errors.isEmpty()) {
            throw new DatasetValidationException(errors);
        }
        return new Dataset(ingredients, recipes);
    }

    private List<Dataset.IngredientData> loadIngredients(Path file, List<DatasetValidationError> errors) {
        MasterJson json = read(file, MasterJson.class, errors);
        if (json == null || json.ingredients() == null || json.ingredients().isEmpty()) {
            error(errors, "INVALID_SCHEMA", file, "ingredients", "must contain at least one ingredient");
            return List.of();
        }

        List<Dataset.IngredientData> result = new ArrayList<>();
        Set<String> ingredientKeys = new HashSet<>();
        Set<String> ingredientNames = new HashSet<>();
        Set<String> variantKeys = new HashSet<>();
        for (int index = 0; index < json.ingredients().size(); index++) {
            IngredientJson ingredient = json.ingredients().get(index);
            String basePath = "ingredients[%d]".formatted(index);
            String key = requiredKey(file, basePath + ".key", ingredient.key(), errors);
            String name = requiredText(file, basePath + ".name", ingredient.name(), errors);
            duplicate(ingredientKeys, key, errors, file, basePath + ".key", "ingredient");
            duplicate(ingredientNames, name, errors, file, basePath + ".name", "ingredient name");

            if (ingredient.variants() == null || ingredient.variants().isEmpty()) {
                error(errors, "INVALID_SCHEMA", file, basePath + ".variants", "must not be empty");
                continue;
            }
            List<Dataset.VariantData> variants = new ArrayList<>();
            Set<String> ownVariantKeys = new HashSet<>();
            int baseCount = 0;
            for (int variantIndex = 0; variantIndex < ingredient.variants().size(); variantIndex++) {
                VariantJson variant = ingredient.variants().get(variantIndex);
                String variantPath = basePath + ".variants[%d]".formatted(variantIndex);
                String variantKey = requiredKey(file, variantPath + ".key", variant.key(), errors);
                String variantName = requiredText(file, variantPath + ".name", variant.name(), errors);
                if (variant.base() == null) {
                    error(errors, "INVALID_SCHEMA", file, variantPath + ".base", "must be boolean");
                    continue;
                }
                duplicate(variantKeys, variantKey, errors, file, variantPath + ".key", "variant");
                ownVariantKeys.add(variantKey);
                if (variant.base()) {
                    baseCount++;
                }
                List<String> aliases = variant.aliases() == null ? List.of() : variant.aliases();
                variants.add(new Dataset.VariantData(variantKey, variantName, variant.base(), aliases));
            }
            if (baseCount != 1) {
                error(errors, "INVALID_SCHEMA", file, basePath + ".variants", "must contain exactly one base variant");
            }

            List<Dataset.RelationData> relations = new ArrayList<>();
            List<RelationJson> relationJsons = ingredient.relations() == null ? List.of() : ingredient.relations();
            for (int relationIndex = 0; relationIndex < relationJsons.size(); relationIndex++) {
                RelationJson relation = relationJsons.get(relationIndex);
                String relationPath = basePath + ".relations[%d]".formatted(relationIndex);
                String source = requiredText(file, relationPath + ".source", relation.source(), errors);
                String target = requiredText(file, relationPath + ".target", relation.target(), errors);
                if (source != null && target != null && source.equals(target)) {
                    error(errors, "INVALID_VARIANT_RELATION", file, relationPath, "source and target must differ");
                }
                if (source != null && !ownVariantKeys.contains(source)) {
                    error(errors, "INVALID_VARIANT_RELATION", file, relationPath + ".source", "must belong to this ingredient");
                }
                if (target != null && !ownVariantKeys.contains(target)) {
                    error(errors, "INVALID_VARIANT_RELATION", file, relationPath + ".target", "must belong to this ingredient");
                }
                relations.add(new Dataset.RelationData(source, target));
            }
            result.add(new Dataset.IngredientData(key, name, variants, relations));
        }
        return result;
    }

    private List<Dataset.RecipeData> loadRecipes(
        Path directory,
        MasterIndex master,
        List<DatasetValidationError> errors
    ) {
        List<Path> files;
        try (Stream<Path> paths = Files.list(directory)) {
            files = paths.filter(Files::isRegularFile)
                .filter(path -> path.getFileName().toString().endsWith(".json"))
                .sorted()
                .toList();
        } catch (IOException exception) {
            error(errors, "INVALID_SCHEMA", directory, null, "cannot list recipe files (%s)".formatted(exception.getMessage()));
            return List.of();
        }

        List<Dataset.RecipeData> recipes = new ArrayList<>();
        Set<String> recipeKeys = new HashSet<>();
        for (Path file : files) {
            RecipeJson json = read(file, RecipeJson.class, errors);
            if (json == null) {
                continue;
            }
            Dataset.RecipeData recipe = validateRecipe(file, json, master, errors);
            if (recipe != null) {
                duplicate(recipeKeys, recipe.key(), errors, file, "key", "recipe");
                recipes.add(recipe);
            }
        }
        return recipes;
    }

    private Dataset.RecipeData validateRecipe(
        Path file,
        RecipeJson recipe,
        MasterIndex master,
        List<DatasetValidationError> errors
    ) {
        int initialErrors = errors.size();
        String key = requiredKey(file, "key", recipe.key(), errors);
        String name = requiredText(file, "name", recipe.name(), errors);
        String status = requiredText(file, "status", recipe.status(), errors);
        String shortsReference = requiredText(file, "shortsReference", recipe.shortsReference(), errors);
        if (status != null && !Set.of("DRAFT", "PUBLISHED").contains(status)) {
            error(errors, "INVALID_SCHEMA", file, "status", "must be DRAFT or PUBLISHED");
        }
        List<Dataset.RecipeIngredientData> ingredients = validateRecipeIngredients(
            file, recipe.ingredients(), status, master, errors
        );
        Map<String, Dataset.RecipeIngredientData> byKey = new HashMap<>();
        ingredients.forEach(ingredient -> byKey.put(ingredient.key(), ingredient));
        List<Dataset.RequirementData> requirements = validateRequirements(
            file, recipe.requirements(), byKey, master, errors
        );
        validatePublishedRoles(file, status, byKey, requirements, errors);
        List<String> steps = validateSteps(file, recipe.steps(), errors);
        if (errors.size() != initialErrors) {
            return null;
        }
        return new Dataset.RecipeData(key, name, status, shortsReference, ingredients, requirements, steps);
    }

    private List<Dataset.RecipeIngredientData> validateRecipeIngredients(
        Path file,
        List<RecipeIngredientJson> jsons,
        String status,
        MasterIndex master,
        List<DatasetValidationError> errors
    ) {
        if (jsons == null || jsons.isEmpty()) {
            error(errors, "INVALID_SCHEMA", file, "ingredients", "must not be empty");
            return List.of();
        }
        List<Dataset.RecipeIngredientData> result = new ArrayList<>();
        Set<String> keys = new HashSet<>();
        for (int index = 0; index < jsons.size(); index++) {
            RecipeIngredientJson json = jsons.get(index);
            String path = "ingredients[%d]".formatted(index);
            String key = requiredKey(file, path + ".key", json.key(), errors);
            String variant = optionalText(json.variant());
            duplicate(keys, key, errors, file, path + ".key", "recipe ingredient");
            if ("PUBLISHED".equals(status) && variant == null) {
                error(errors, "INVALID_PUBLISHED_RECIPE", file, path + ".variant", "is required for PUBLISHED recipes");
            }
            if (variant != null && !master.ingredientKeyByVariant().containsKey(variant)) {
                error(errors, "UNKNOWN_REFERENCE", file, path + ".variant", "unknown variant '%s'".formatted(variant));
            }
            if (json.optional() == null) {
                error(errors, "INVALID_SCHEMA", file, path + ".optional", "must be boolean");
            }
            result.add(new Dataset.RecipeIngredientData(
                key, variant, requiredText(file, path + ".displayName", json.displayName(), errors),
                requiredText(file, path + ".rawText", json.rawText(), errors), optionalText(json.amount()),
                optionalText(json.unit()), Boolean.TRUE.equals(json.optional())
            ));
        }
        return result;
    }

    private List<Dataset.RequirementData> validateRequirements(
        Path file,
        List<RequirementJson> jsons,
        Map<String, Dataset.RecipeIngredientData> ingredients,
        MasterIndex master,
        List<DatasetValidationError> errors
    ) {
        if (jsons == null) {
            error(errors, "INVALID_SCHEMA", file, "requirements", "must be an array");
            return List.of();
        }
        List<Dataset.RequirementData> result = new ArrayList<>();
        for (int index = 0; index < jsons.size(); index++) {
            RequirementJson json = jsons.get(index);
            String path = "requirements[%d]".formatted(index);
            if (json.options() == null || json.options().isEmpty()) {
                error(errors, "INVALID_REQUIREMENT", file, path + ".options", "must contain at least one option");
                continue;
            }
            List<Dataset.RequirementOptionData> options = new ArrayList<>();
            for (int optionIndex = 0; optionIndex < json.options().size(); optionIndex++) {
                RequirementOptionJson option = json.options().get(optionIndex);
                String optionPath = path + ".options[%d]".formatted(optionIndex);
                String ingredientKey = requiredText(file, optionPath + ".ingredient", option.ingredient(), errors);
                Dataset.RecipeIngredientData original = ingredients.get(ingredientKey);
                if (original == null) {
                    error(errors, "UNKNOWN_REFERENCE", file, optionPath + ".ingredient", "unknown recipe ingredient");
                } else if (original.optional()) {
                    error(errors, "INVALID_REQUIREMENT", file, optionPath + ".ingredient", "optional ingredients cannot participate");
                }
                List<String> substitutes = option.substitutes() == null ? List.of() : option.substitutes();
                List<String> allowedVariants = option.allowedVariants() == null ? List.of() : option.allowedVariants();
                for (int substituteIndex = 0; substituteIndex < substitutes.size(); substituteIndex++) {
                    String substituteKey = substitutes.get(substituteIndex);
                    Dataset.RecipeIngredientData substitute = ingredients.get(substituteKey);
                    String substitutePath = optionPath + ".substitutes[%d]".formatted(substituteIndex);
                    if (substitute == null) {
                        error(errors, "UNKNOWN_REFERENCE", file, substitutePath, "unknown recipe ingredient");
                    } else if (substitute.optional() || substituteKey.equals(ingredientKey)) {
                        error(errors, "INVALID_REQUIREMENT", file, substitutePath, "must be a different non-optional ingredient");
                    }
                }
                for (int variantIndex = 0; variantIndex < allowedVariants.size(); variantIndex++) {
                    String allowed = allowedVariants.get(variantIndex);
                    String allowedPath = optionPath + ".allowedVariants[%d]".formatted(variantIndex);
                    String originalIngredient = original == null ? null : master.ingredientKeyByVariant().get(original.variant());
                    String allowedIngredient = master.ingredientKeyByVariant().get(allowed);
                    if (allowedIngredient == null) {
                        error(errors, "UNKNOWN_REFERENCE", file, allowedPath, "unknown variant '%s'".formatted(allowed));
                    } else if (originalIngredient == null || !originalIngredient.equals(allowedIngredient)
                        || allowed.equals(original.variant())) {
                        error(errors, "INVALID_ALLOWED_VARIANT", file, allowedPath, "must be a different variant of the option ingredient");
                    }
                }
                options.add(new Dataset.RequirementOptionData(ingredientKey, substitutes, allowedVariants));
            }
            result.add(new Dataset.RequirementData(options));
        }
        return result;
    }

    private void validatePublishedRoles(
        Path file,
        String status,
        Map<String, Dataset.RecipeIngredientData> ingredients,
        List<Dataset.RequirementData> requirements,
        List<DatasetValidationError> errors
    ) {
        if (!"PUBLISHED".equals(status)) {
            return;
        }
        Map<String, Integer> roles = new HashMap<>();
        for (Dataset.RequirementData requirement : requirements) {
            for (Dataset.RequirementOptionData option : requirement.options()) {
                roles.merge(option.ingredient(), 1, Integer::sum);
                option.substitutes().forEach(key -> roles.merge(key, 1, Integer::sum));
            }
        }
        ingredients.forEach((key, ingredient) -> {
            if (!ingredient.optional() && roles.getOrDefault(key, 0) != 1) {
                error(errors, "INVALID_PUBLISHED_RECIPE", file, "ingredients", "non-optional ingredient '%s' must have exactly one requirement role".formatted(key));
            }
        });
    }

    private List<String> validateSteps(Path file, List<String> steps, List<DatasetValidationError> errors) {
        if (steps == null || steps.isEmpty()) {
            error(errors, "INVALID_SCHEMA", file, "steps", "must not be empty");
            return List.of();
        }
        List<String> result = new ArrayList<>();
        for (int index = 0; index < steps.size(); index++) {
            result.add(requiredText(file, "steps[%d]".formatted(index), steps.get(index), errors));
        }
        return result;
    }

    private MasterIndex indexMaster(List<Dataset.IngredientData> ingredients) {
        Map<String, String> result = new HashMap<>();
        for (Dataset.IngredientData ingredient : ingredients) {
            ingredient.variants().forEach(variant -> result.put(variant.key(), ingredient.key()));
        }
        return new MasterIndex(result);
    }

    private <T> T read(Path file, Class<T> type, List<DatasetValidationError> errors) {
        try {
            return objectMapper.readValue(file.toFile(), type);
        } catch (JacksonException exception) {
            error(errors, "INVALID_SCHEMA", file, null, "invalid JSON (%s)".formatted(exception.getMessage()));
        }
        return null;
    }

    private String requiredKey(Path file, String path, String value, List<DatasetValidationError> errors) {
        String key = requiredText(file, path, value, errors);
        if (key != null && !KEBAB_KEY.matcher(key).matches()) {
            error(errors, "INVALID_SCHEMA", file, path, "must be lowercase ASCII kebab-case");
        }
        return key;
    }

    private String requiredText(Path file, String path, String value, List<DatasetValidationError> errors) {
        String text = optionalText(value);
        if (text == null) {
            error(errors, "INVALID_SCHEMA", file, path, "must not be blank");
        }
        return text;
    }

    private String optionalText(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private void duplicate(
        Set<String> values,
        String value,
        List<DatasetValidationError> errors,
        Path file,
        String path,
        String type
    ) {
        if (value != null && !values.add(value)) {
            error(errors, "DUPLICATE_KEY", file, path, "duplicate %s '%s'".formatted(type, value));
        }
    }

    private void error(List<DatasetValidationError> errors, String code, Path file, String path, String message) {
        errors.add(new DatasetValidationError(code, file.toString(), path, message));
    }

    private record MasterIndex(Map<String, String> ingredientKeyByVariant) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record MasterJson(List<IngredientJson> ingredients) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record IngredientJson(String key, String name, List<VariantJson> variants, List<RelationJson> relations) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record VariantJson(String key, String name, Boolean base, List<String> aliases) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record RelationJson(String source, String target) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record RecipeJson(
        String key, String name, String status, String shortsReference,
        List<RecipeIngredientJson> ingredients, List<RequirementJson> requirements, List<String> steps
    ) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record RecipeIngredientJson(
        String key, String variant, String displayName, String rawText, String amount, String unit, Boolean optional
    ) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record RequirementJson(List<RequirementOptionJson> options) { }

    @JsonIgnoreProperties(ignoreUnknown = false)
    private record RequirementOptionJson(String ingredient, List<String> substitutes, List<String> allowedVariants) { }
}
