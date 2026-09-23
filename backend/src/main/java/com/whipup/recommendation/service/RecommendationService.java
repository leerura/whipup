package com.whipup.recommendation.service;

import com.whipup.generated.model.MissingIngredient;
import com.whipup.generated.model.RecommendationItem;
import com.whipup.generated.model.RecommendationPage;
import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeIngredient;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.repository.RecipeRepository;
import com.whipup.recommendation.exception.RecommendationException;
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
public class RecommendationService {

    private static final String YOUTUBE_THUMBNAIL_URL =
        "https://img.youtube.com/vi/%s/hqdefault.jpg";

    private final RecipeRepository recipeRepository;
    private final UserIngredientRepository userIngredientRepository;

    public RecommendationService(
        RecipeRepository recipeRepository,
        UserIngredientRepository userIngredientRepository
    ) {
        this.recipeRepository = recipeRepository;
        this.userIngredientRepository = userIngredientRepository;
    }

    @Transactional(readOnly = true)
    public RecommendationPage getRecommendations(
        Long userId,
        Integer missingCount,
        Integer page,
        Integer size
    ) {
        RecommendationItem.MissingCountEnum missingCountEnum = toMissingCountEnum(
            missingCount
        );

        Set<Long> ownedIngredientIds = userIngredientRepository
            .findAllByUser_IdOrderByIngredient_CanonicalNameAsc(userId)
            .stream()
            .map(UserIngredient::getIngredient)
            .map(Ingredient::getId)
            .collect(Collectors.toSet());

        if (ownedIngredientIds.isEmpty()) {
            throw RecommendationException.noOwnedIngredients();
        }

        List<RecommendationItem> allItems = recipeRepository
            .findAllByStatusOrderByIdAsc(RecipeStatus.PUBLISHED)
            .stream()
            .map(recipe -> toCandidate(recipe, ownedIngredientIds))
            .filter(candidate -> candidate.missingIngredients().size() == missingCount)
            .map(candidate -> toRecommendationItem(candidate, missingCountEnum))
            .toList();

        int fromIndex = Math.min(page * size, allItems.size());
        int toIndex = Math.min(fromIndex + size, allItems.size());

        return new RecommendationPage(
            allItems.subList(fromIndex, toIndex),
            page,
            size,
            toIndex < allItems.size()
        );
    }

    private RecommendationCandidate toCandidate(
        Recipe recipe,
        Set<Long> ownedIngredientIds
    ) {
        List<MissingIngredient> missingIngredients = recipe
            .getIngredients()
            .stream()
            .filter(recipeIngredient -> !ownedIngredientIds.contains(
                recipeIngredient.getIngredient().getId()
            ))
            .sorted(Comparator.comparingInt(RecipeIngredient::getDisplayOrder))
            .map(recipeIngredient -> new MissingIngredient(
                recipeIngredient.getIngredient().getId(),
                recipeIngredient.getIngredient().getCanonicalName()
            ))
            .toList();

        return new RecommendationCandidate(recipe, missingIngredients);
    }

    private RecommendationItem toRecommendationItem(
        RecommendationCandidate candidate,
        RecommendationItem.MissingCountEnum missingCount
    ) {
        Recipe recipe = candidate.recipe();
        URI shortsReference = URI.create(recipe.getShortsReference());
        URI thumbnailUrl = URI.create(YOUTUBE_THUMBNAIL_URL.formatted(
            extractYoutubeVideoId(shortsReference)
        ));

        return new RecommendationItem(
            recipe.getId(),
            recipe.getName(),
            thumbnailUrl,
            missingCount,
            candidate.missingIngredients()
        );
    }

    private RecommendationItem.MissingCountEnum toMissingCountEnum(
        Integer missingCount
    ) {
        try {
            return RecommendationItem.MissingCountEnum.fromValue(missingCount);
        } catch (IllegalArgumentException exception) {
            throw RecommendationException.invalidRequest();
        }
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

    private record RecommendationCandidate(
        Recipe recipe,
        List<MissingIngredient> missingIngredients
    ) {
    }
}
