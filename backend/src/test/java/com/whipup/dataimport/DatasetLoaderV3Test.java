package com.whipup.dataimport;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import tools.jackson.databind.ObjectMapper;

class DatasetLoaderV3Test {

    @TempDir
    Path temporaryDirectory;

    private final DatasetLoader loader = new DatasetLoader(new ObjectMapper());

    @Test
    void acceptsGroupsWithoutBaseAndCrossGroupAcceptedCandidates() throws IOException {
        writeDataset("[\"other-item\"]");

        Dataset dataset = loader.load(temporaryDirectory);

        assertEquals(2, dataset.ingredients().size());
        assertEquals(List.of("other-item"), dataset.recipes().get(0).ingredients().get(0)
            .acceptedOwnedVariants());
    }

    @Test
    void rejectsPublishedRequiredIngredientWithoutAnyCandidate() throws IOException {
        writeDataset("[]");

        DatasetValidationException exception = assertThrows(
            DatasetValidationException.class,
            () -> loader.load(temporaryDirectory)
        );

        assertTrue(exception.getErrors().stream().anyMatch(error ->
            error.path().equals("ingredients[0]") && error.code().equals("INVALID_PUBLISHED_RECIPE")));
    }

    @Test
    void rejectsDuplicateAcceptedCandidates() throws IOException {
        writeDataset("[\"other-item\", \"other-item\"]");

        DatasetValidationException exception = assertThrows(
            DatasetValidationException.class,
            () -> loader.load(temporaryDirectory)
        );

        assertTrue(exception.getErrors().stream().anyMatch(error ->
            error.path().equals("ingredients[0].acceptedOwnedVariants[1]")
                && error.code().equals("DUPLICATE_KEY")));
    }

    @Test
    void rejectsUnknownAcceptedCandidate() throws IOException {
        writeDataset("[\"missing-item\"]");

        DatasetValidationException exception = assertThrows(
            DatasetValidationException.class,
            () -> loader.load(temporaryDirectory)
        );

        assertTrue(exception.getErrors().stream().anyMatch(error ->
            error.path().equals("ingredients[0].acceptedOwnedVariants[0]")
                && error.code().equals("UNKNOWN_REFERENCE")));
    }

    private void writeDataset(String acceptedOwnedVariants) throws IOException {
        Files.writeString(temporaryDirectory.resolve("ingredients.json"), """
            {"ingredients":[
              {"key":"source-group","name":"원문 재료","variants":[{"key":"source-item","name":"원문 항목"}]},
              {"key":"other-group","name":"다른 그룹","variants":[{"key":"other-item","name":"다른 항목"}]}
            ]}
            """);
        Path recipes = Files.createDirectories(temporaryDirectory.resolve("recipes"));
        Files.writeString(recipes.resolve("recipe.json"), """
            {
              "key":"recipe", "name":"테스트 레시피", "status":"PUBLISHED",
              "shortsReference":"https://example.com/video",
              "ingredients":[{"key":"source","variant":null,"acceptedOwnedVariants":%s,
                "displayName":"원문 재료","rawText":"원문 재료 1개","amount":"1","unit":"개","optional":false}],
              "requirements":[{"options":[{"ingredient":"source","substitutes":[],"allowedVariants":[]}]}],
              "steps":["조리한다."]
            }
            """.formatted(acceptedOwnedVariants));
    }
}
