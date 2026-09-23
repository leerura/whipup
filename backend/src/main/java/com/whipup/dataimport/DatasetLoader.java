package com.whipup.dataimport;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.stereotype.Component;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

@Component
public class DatasetLoader {

    private static final String INGREDIENT_HEADER = "canonical_name";
    private static final String MAPPED = "MAPPED";

    private final ObjectMapper objectMapper;

    public DatasetLoader(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public Dataset load(Path dataDirectory) {
        List<String> errors = new ArrayList<>();
        Set<String> ingredientNames = loadIngredients(dataDirectory.resolve("ingredients.csv"), errors);
        List<Dataset.RecipeData> recipes = loadRecipes(
            dataDirectory.resolve("recipes"),
            ingredientNames,
            errors
        );

        if (!errors.isEmpty()) {
            throw new DatasetValidationException(errors);
        }
        return new Dataset(ingredientNames, recipes);
    }

    private Set<String> loadIngredients(Path path, List<String> errors) {
        List<String> lines;
        try {
            lines = Files.readAllLines(path, StandardCharsets.UTF_8);
        } catch (IOException exception) {
            errors.add("%s: cannot read file (%s)".formatted(path, exception.getMessage()));
            return Set.of();
        }

        if (lines.isEmpty()) {
            errors.add("%s: file is empty".formatted(path));
            return Set.of();
        }

        String header = removeBom(lines.get(0)).trim();
        if (!INGREDIENT_HEADER.equals(header)) {
            errors.add("%s: expected header '%s'".formatted(path, INGREDIENT_HEADER));
        }

        Set<String> ingredientNames = new LinkedHashSet<>();
        for (int index = 1; index < lines.size(); index++) {
            int lineNumber = index + 1;
            String name = lines.get(index).trim();
            if (name.isEmpty()) {
                errors.add("%s:%d: canonical_name must not be blank".formatted(path, lineNumber));
                continue;
            }
            if (name.contains(",")) {
                errors.add("%s:%d: expected exactly one CSV column".formatted(path, lineNumber));
                continue;
            }
            if (!ingredientNames.add(name)) {
                errors.add("%s:%d: duplicate canonical_name '%s'".formatted(path, lineNumber, name));
            }
        }
        return ingredientNames;
    }

    private List<Dataset.RecipeData> loadRecipes(
        Path directory,
        Set<String> ingredientNames,
        List<String> errors
    ) {
        List<Path> recipeFiles;
        try (Stream<Path> paths = Files.list(directory)) {
            recipeFiles = paths
                .filter(Files::isRegularFile)
                .filter(path -> path.getFileName().toString().endsWith(".json"))
                .sorted()
                .toList();
        } catch (IOException exception) {
            errors.add("%s: cannot list recipe files (%s)".formatted(directory, exception.getMessage()));
            return List.of();
        }

        if (recipeFiles.isEmpty()) {
            errors.add("%s: no recipe JSON files found".formatted(directory));
            return List.of();
        }

        List<Dataset.RecipeData> recipes = new ArrayList<>();
        Set<String> recipeKeys = new HashSet<>();
        for (Path recipeFile : recipeFiles) {
            RecipeJson recipeJson;
            try {
                recipeJson = objectMapper.readValue(recipeFile.toFile(), RecipeJson.class);
            } catch (JacksonException exception) {
                errors.add("%s: invalid JSON (%s)".formatted(recipeFile, exception.getMessage()));
                continue;
            }

            Dataset.RecipeData recipe = validateRecipe(
                recipeFile,
                recipeJson,
                ingredientNames,
                recipeKeys,
                errors
            );
            if (recipe != null) {
                recipes.add(recipe);
            }
        }
        return recipes;
    }

    private Dataset.RecipeData validateRecipe(
        Path path,
        RecipeJson recipe,
        Set<String> ingredientNames,
        Set<String> recipeKeys,
        List<String> errors
    ) {
        int initialErrorCount = errors.size();
        String key = requireText(path, "key", recipe.key(), errors);
        String name = requireText(path, "name", recipe.name(), errors);
        String shortsReference = requireText(path, "shortsReference", recipe.shortsReference(), errors);

        if (key != null && !recipeKeys.add(key)) {
            errors.add("%s: duplicate recipe key '%s'".formatted(path, key));
        }

        List<Dataset.RecipeIngredientData> ingredients = validateRecipeIngredients(
            path,
            recipe.ingredients(),
            ingredientNames,
            errors
        );
        List<String> steps = validateSteps(path, recipe.steps(), errors);

        if (errors.size() != initialErrorCount) {
            return null;
        }
        return new Dataset.RecipeData(key, name, shortsReference, ingredients, steps);
    }

    private List<Dataset.RecipeIngredientData> validateRecipeIngredients(
        Path path,
        List<RecipeIngredientJson> ingredients,
        Set<String> ingredientNames,
        List<String> errors
    ) {
        if (ingredients == null || ingredients.isEmpty()) {
            errors.add("%s: ingredients must not be empty".formatted(path));
            return List.of();
        }

        List<Dataset.RecipeIngredientData> validated = new ArrayList<>();
        Set<String> recipeIngredientNames = new HashSet<>();
        for (int index = 0; index < ingredients.size(); index++) {
            RecipeIngredientJson ingredient = ingredients.get(index);
            String field = "ingredients[%d]".formatted(index);
            int initialErrorCount = errors.size();
            String canonicalIngredient = requireText(
                path,
                field + ".canonicalIngredient",
                ingredient.canonicalIngredient(),
                errors
            );
            String displayName = requireText(path, field + ".displayName", ingredient.displayName(), errors);
            String rawText = requireText(path, field + ".rawText", ingredient.rawText(), errors);

            if (!MAPPED.equals(ingredient.mappingStatus())) {
                errors.add("%s: %s.mappingStatus must be MAPPED".formatted(path, field));
            }
            if (canonicalIngredient != null && !ingredientNames.contains(canonicalIngredient)) {
                errors.add("%s: %s canonical ingredient '%s' is not in ingredients.csv"
                    .formatted(path, field, canonicalIngredient));
            }
            if (canonicalIngredient != null && !recipeIngredientNames.add(canonicalIngredient)) {
                errors.add("%s: duplicate canonical ingredient '%s'".formatted(path, canonicalIngredient));
            }

            if (errors.size() == initialErrorCount) {
                validated.add(new Dataset.RecipeIngredientData(
                    canonicalIngredient,
                    displayName,
                    rawText,
                    trimToNull(ingredient.amount()),
                    trimToNull(ingredient.unit())
                ));
            }
        }
        return validated;
    }

    private List<String> validateSteps(Path path, List<String> steps, List<String> errors) {
        if (steps == null || steps.isEmpty()) {
            errors.add("%s: steps must not be empty".formatted(path));
            return List.of();
        }

        List<String> validated = new ArrayList<>();
        for (int index = 0; index < steps.size(); index++) {
            String step = requireText(path, "steps[%d]".formatted(index), steps.get(index), errors);
            if (step != null) {
                validated.add(step);
            }
        }
        return validated;
    }

    private String requireText(Path path, String field, String value, List<String> errors) {
        String trimmed = trimToNull(value);
        if (trimmed == null) {
            errors.add("%s: %s must not be blank".formatted(path, field));
        }
        return trimmed;
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String removeBom(String value) {
        return value.startsWith("\uFEFF") ? value.substring(1) : value;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record RecipeJson(
        String key,
        String name,
        String shortsReference,
        List<RecipeIngredientJson> ingredients,
        List<String> steps
    ) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record RecipeIngredientJson(
        String canonicalIngredient,
        String displayName,
        String rawText,
        String amount,
        String unit,
        String mappingStatus
    ) {
    }
}
