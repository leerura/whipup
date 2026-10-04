package com.whipup.recommendation.service;

import com.whipup.generated.model.IngredientMatch;
import com.whipup.generated.model.MissingOption;
import com.whipup.generated.model.MissingRequirementResult;
import com.whipup.generated.model.MissingSubstitute;
import com.whipup.generated.model.RecommendationItem;
import com.whipup.generated.model.RecommendationListResponse;
import com.whipup.generated.model.RecommendationMode;
import com.whipup.generated.model.RequirementResult;
import com.whipup.generated.model.SatisfiedRequirementResult;
import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeRequirementOption;
import com.whipup.recipe.domain.RecipeRequirementSubstitute;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.repository.RecipeRepository;
import com.whipup.recipe.service.RecipeMatchResult;
import com.whipup.recipe.service.RecipeMatchResult.IngredientMatchResult;
import com.whipup.recipe.service.RecipeMatchService;
import com.whipup.recipe.service.RecipeMatchService.MatchedRecipe;
import com.whipup.recommendation.exception.RecommendationException;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RecommendationService {

    private static final String YOUTUBE_THUMBNAIL_URL =
        "https://img.youtube.com/vi/%s/hqdefault.jpg";

    private final RecipeRepository recipeRepository;
    private final UserIngredientRepository userIngredientRepository;
    private final RecipeMatchService recipeMatchService;

    public RecommendationService(
        RecipeRepository recipeRepository,
        UserIngredientRepository userIngredientRepository,
        RecipeMatchService recipeMatchService
    ) {
        this.recipeRepository = recipeRepository;
        this.userIngredientRepository = userIngredientRepository;
        this.recipeMatchService = recipeMatchService;
    }

    @Transactional(readOnly = true)
    public RecommendationListResponse getRecipeRecommendations(
        Long userId,
        RecommendationMode mode
    ) {
        if (mode == null) {
            throw RecommendationException.invalidRequest();
        }

        List<IngredientVariant> ownedVariants = userIngredientRepository
            .findAllByUser_IdOrderByIngredientVariant_NameAsc(userId)
            .stream()
            .map(UserIngredient::getIngredientVariant)
            .toList();

        if (ownedVariants.isEmpty()) {
            throw RecommendationException.noOwnedIngredients();
        }

        List<Recipe> recipes = recipeRepository
            .findAllByStatusOrderByIdAsc(RecipeStatus.PUBLISHED);

        List<RecommendationItem> items = recipeMatchService
            .matchAll(recipes, ownedVariants)
            .stream()
            .filter(matchedRecipe -> matchesMode(matchedRecipe, mode))
            .sorted(recommendationComparator(mode))
            .map(this::toRecommendationItem)
            .toList();

        return new RecommendationListResponse(items);
    }

    private boolean matchesMode(
        MatchedRecipe matchedRecipe,
        RecommendationMode mode
    ) {
        int missingCount = matchedRecipe.matchResult().missingCount();

        return switch (mode) {
            case AVAILABLE -> missingCount == 0;
            case MISSING_INGREDIENTS -> missingCount >= 1;
        };
    }

    private Comparator<MatchedRecipe> recommendationComparator(
        RecommendationMode mode
    ) {
        if (mode == RecommendationMode.AVAILABLE) {
            return Comparator.comparing(matchedRecipe ->
                matchedRecipe.recipe().getId()
            );
        }

        return Comparator
            .comparingInt((MatchedRecipe matchedRecipe) ->
                matchedRecipe.matchResult().missingCount()
            )
            .thenComparing(matchedRecipe -> matchedRecipe.recipe().getId());
    }

    private RecommendationItem toRecommendationItem(MatchedRecipe matchedRecipe) {
        Recipe recipe = matchedRecipe.recipe();
        RecipeMatchResult matchResult = matchedRecipe.matchResult();
        URI shortsReference = URI.create(recipe.getShortsReference());
        URI thumbnailUrl = URI.create(YOUTUBE_THUMBNAIL_URL.formatted(
            extractYoutubeVideoId(shortsReference)
        ));

        List<RequirementResult> requirementResults = matchResult.requirements()
            .stream()
            .map(this::toRequirementResult)
            .toList();

        return new RecommendationItem(
            recipe.getId(),
            recipe.getName(),
            thumbnailUrl,
            matchResult.missingCount(),
            requirementResults
        );
    }

    private RequirementResult toRequirementResult(
        RecipeMatchResult.RequirementResult result
    ) {
        if (result.satisfied()) {
            List<IngredientMatch> matches = result.matches()
                .stream()
                .map(this::toIngredientMatch)
                .toList();

            return new SatisfiedRequirementResult(
                SatisfiedRequirementResult.StatusEnum.SATISFIED,
                matches
            );
        }

        List<MissingOption> missingOptions = result.requirement()
            .getOptions()
            .stream()
            .sorted(Comparator.comparingInt(
                RecipeRequirementOption::getDisplayOrder
            ))
            .map(this::toMissingOption)
            .toList();

        return new MissingRequirementResult(
            MissingRequirementResult.StatusEnum.MISSING,
            missingOptions
        );
    }

    private IngredientMatch toIngredientMatch(IngredientMatchResult match) {
        return new IngredientMatch(
            toMatchType(match),
            match.option().getIngredient().getDisplayName(),
            match.ownedVariant().getName()
        );
    }

    private IngredientMatch.TypeEnum toMatchType(IngredientMatchResult match) {
        return switch (match.type()) {
            case DIRECT -> IngredientMatch.TypeEnum.DIRECT;
            case PREPARATION -> IngredientMatch.TypeEnum.PREPARATION;
            case SUBSTITUTE -> IngredientMatch.TypeEnum.SUBSTITUTE;
        };
    }

    private MissingOption toMissingOption(RecipeRequirementOption option) {
        List<MissingSubstitute> substitutes = option.getSubstitutes()
            .stream()
            .sorted(Comparator.comparingInt(
                RecipeRequirementSubstitute::getDisplayOrder
            ))
            .map(substitute -> new MissingSubstitute(
                substitute.getIngredient().getDisplayName()
            ))
            .toList();

        return new MissingOption(
            option.getIngredient().getDisplayName(),
            substitutes
        );
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
