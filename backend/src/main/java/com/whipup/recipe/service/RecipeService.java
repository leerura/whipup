package com.whipup.recipe.service;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.generated.model.RecipeDetailResponse;
import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.exception.RecipeNotFoundException;
import com.whipup.recipe.repository.RecipeRepository;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RecipeService {

    private static final String YOUTUBE_THUMBNAIL_URL =
        "https://img.youtube.com/vi/%s/hqdefault.jpg";

    private final RecipeRepository recipeRepository;
    private final UserIngredientRepository userIngredientRepository;
    private final CurrentUserProvider currentUserProvider;

    public RecipeService(
        RecipeRepository recipeRepository,
        UserIngredientRepository userIngredientRepository,
        CurrentUserProvider currentUserProvider
    ) {
        this.recipeRepository = recipeRepository;
        this.userIngredientRepository = userIngredientRepository;
        this.currentUserProvider = currentUserProvider;
    }

    @Transactional(readOnly = true)
    public RecipeDetailResponse getRecipeDetail(Long recipeId) {
        Long userId = currentUserProvider.getUserId();
        Recipe recipe = recipeRepository
            .findByIdAndStatus(recipeId, RecipeStatus.PUBLISHED)
            .orElseThrow(RecipeNotFoundException::new);

        Set<Long> ownedIngredientIds = userIngredientRepository
            .findAllByUser_IdOrderByIngredient_CanonicalNameAsc(userId)
            .stream()
            .map(UserIngredient::getIngredient)
            .map(Ingredient::getId)
            .collect(Collectors.toSet());

        List<com.whipup.generated.model.RecipeIngredient> ingredients = recipe
            .getIngredients()
            .stream()
            .sorted(Comparator.comparingInt(
                com.whipup.recipe.domain.RecipeIngredient::getDisplayOrder
            ))
            .map(ingredient -> toResponse(ingredient, ownedIngredientIds))
            .toList();

        List<com.whipup.generated.model.RecipeStep> steps = recipe
            .getSteps()
            .stream()
            .sorted(Comparator.comparingInt(
                com.whipup.recipe.domain.RecipeStep::getStepOrder
            ))
            .map(step -> new com.whipup.generated.model.RecipeStep(
                step.getStepOrder(),
                step.getContent()
            ))
            .toList();

        int missingCount = (int) recipe
            .getIngredients()
            .stream()
            .map(com.whipup.recipe.domain.RecipeIngredient::getIngredient)
            .map(Ingredient::getId)
            .distinct()
            .filter(ingredientId -> !ownedIngredientIds.contains(ingredientId))
            .count();

        URI shortsReference = URI.create(recipe.getShortsReference());
        URI thumbnailUrl = URI.create(YOUTUBE_THUMBNAIL_URL.formatted(
            extractYoutubeVideoId(shortsReference)
        ));

        return new RecipeDetailResponse(
            recipe.getId(),
            recipe.getName(),
            shortsReference,
            thumbnailUrl,
            missingCount,
            ingredients,
            steps
        );
    }

    private com.whipup.generated.model.RecipeIngredient toResponse(
        com.whipup.recipe.domain.RecipeIngredient ingredient,
        Set<Long> ownedIngredientIds
    ) {
        Long ingredientId = ingredient.getIngredient().getId();
        return new com.whipup.generated.model.RecipeIngredient(
            ingredient.getId(),
            ingredientId,
            ingredient.getDisplayName(),
            ingredient.getDisplayOrder(),
            ownedIngredientIds.contains(ingredientId)
        )
            .amount(ingredient.getAmount())
            .unit(ingredient.getUnit());
    }

    private String extractYoutubeVideoId(URI reference) {
        String host = reference.getHost();
        if (host == null) {
            throw new IllegalStateException("YouTube reference does not contain a host");
        }

        String normalizedHost = host.startsWith("www.") ? host.substring(4) : host;
        List<String> pathSegments = Arrays.stream(reference.getPath().split("/"))
            .filter(segment -> !segment.isBlank())
            .toList();

        if (normalizedHost.equals("youtu.be") && !pathSegments.isEmpty()) {
            return pathSegments.get(0);
        }

        if (normalizedHost.equals("youtube.com")) {
            if (pathSegments.size() >= 2
                && (pathSegments.get(0).equals("shorts")
                    || pathSegments.get(0).equals("embed"))) {
                return pathSegments.get(1);
            }

            if (pathSegments.size() == 1 && pathSegments.get(0).equals("watch")) {
                return findQueryParameter(reference.getRawQuery(), "v");
            }
        }

        throw new IllegalStateException("Unsupported YouTube reference: " + reference);
    }

    private String findQueryParameter(String query, String name) {
        if (query == null) {
            throw new IllegalStateException("YouTube reference does not contain video id");
        }

        return Arrays.stream(query.split("&"))
            .map(parameter -> parameter.split("=", 2))
            .filter(parts -> parts.length == 2 && parts[0].equals(name))
            .map(parts -> URLDecoder.decode(parts[1], StandardCharsets.UTF_8))
            .findFirst()
            .orElseThrow(() -> new IllegalStateException(
                "YouTube reference does not contain video id"
            ));
    }
}
