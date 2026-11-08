package com.whipup.recommendation.service;

import com.whipup.generated.model.IngredientMatch;
import com.whipup.generated.model.MissingOption;
import com.whipup.generated.model.MissingRequirementResult;
import com.whipup.generated.model.MissingSubstitute;
import com.whipup.generated.model.RecommendationItem;
import com.whipup.generated.model.RecommendationListResponse;
import com.whipup.generated.model.RecommendationMode;
import com.whipup.generated.model.RecipeSearchScope;
import com.whipup.generated.model.RequirementResult;
import com.whipup.generated.model.SatisfiedRequirementResult;
import com.whipup.common.observability.WhipupMetrics;
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
    private final WhipupMetrics metrics;

    public RecommendationService(
        RecipeRepository recipeRepository,
        UserIngredientRepository userIngredientRepository,
        RecipeMatchService recipeMatchService,
        WhipupMetrics metrics
    ) {
        this.recipeRepository = recipeRepository;
        this.userIngredientRepository = userIngredientRepository;
        this.recipeMatchService = recipeMatchService;
        this.metrics = metrics;
    }

    @Transactional(readOnly = true)
    public RecommendationListResponse getRecipeRecommendations(
        Long userId,
        RecommendationMode mode
    ) {
        if (mode == null) {
            throw RecommendationException.invalidRequest();
        }

        LoadedRecommendationData loaded = metrics.record("whipup.recommendation.load", () ->
            new LoadedRecommendationData(
                userIngredientRepository.findAllByUser_IdOrderByIngredientVariant_NameAsc(userId)
                    .stream().map(UserIngredient::getIngredientVariant).toList(),
                recipeRepository.findAllByStatusOrderByIdAsc(RecipeStatus.PUBLISHED)
            ));
        List<IngredientVariant> ownedVariants = loaded.ownedVariants();

        if (ownedVariants.isEmpty()) {
            throw RecommendationException.noOwnedIngredients();
        }

        List<MatchedRecipe> matched = metrics.record("whipup.recommendation.match", () -> recipeMatchService
            .matchAll(loaded.recipes(), ownedVariants)
            .stream()
            .filter(matchedRecipe -> matchesMode(matchedRecipe, mode))
            .sorted(recommendationComparator(mode))
            .toList());
        List<RecommendationItem> items = metrics.record("whipup.recommendation.project", () ->
            matched.stream().map(this::toRecommendationItem).toList());

        return new RecommendationListResponse(items);
    }

    @Transactional(readOnly = true)
    public RecommendationListResponse toRecommendationItems(
        Long userId,
        List<Recipe> recipes
    ) {
        List<IngredientVariant> ownedVariants = userIngredientRepository
            .findAllByUser_IdOrderByIngredientVariant_NameAsc(userId)
            .stream()
            .map(UserIngredient::getIngredientVariant)
            .toList();
        return new RecommendationListResponse(recipeMatchService
            .matchAll(recipes, ownedVariants)
            .stream()
            .map(this::toRecommendationItem)
            .toList());
    }

    @Transactional(readOnly = true)
    public RecommendationListResponse searchRecipes(
        Long userId,
        RecipeSearchScope scope,
        String query
    ) {
        if (scope == null || query == null || query.isBlank()) {
            throw RecommendationException.invalidRequest();
        }
        return metrics.record("whipup.recipe.search", () -> {
            String normalizedQuery = normalize(query);
            List<IngredientVariant> ownedVariants = userIngredientRepository
                .findAllByUser_IdOrderByIngredientVariant_NameAsc(userId).stream()
                .map(UserIngredient::getIngredientVariant).toList();
            List<MatchedRecipe> matched = recipeMatchService
                .matchAll(recipeRepository.findAllByStatusOrderByIdAsc(RecipeStatus.PUBLISHED), ownedVariants)
                .stream().filter(item -> matchesSearch(item.recipe(), normalizedQuery))
                .filter(item -> scope == RecipeSearchScope.AVAILABLE
                    ? item.matchResult().missingCount() == 0
                    : item.matchResult().missingCount() >= 1)
                .sorted(searchComparator(scope, normalizedQuery)).toList();
            return new RecommendationListResponse(matched.stream().map(this::toRecommendationItem).toList());
        }, "scope", scope.name());
    }

    private boolean matchesSearch(Recipe recipe, String query) {
        if (normalize(recipe.getName()).contains(query)) {
            return true;
        }
        return recipe.getIngredients().stream()
            .anyMatch(ingredient -> normalize(ingredient.getDisplayName()).contains(query));
    }

    private Comparator<MatchedRecipe> searchComparator(
        RecipeSearchScope scope,
        String query
    ) {
        return Comparator
            .comparing((MatchedRecipe item) -> scope == RecipeSearchScope.ALL
                ? item.matchResult().missingCount() : 0)
            .thenComparing(item -> normalize(item.recipe().getName()).startsWith(query) ? 0 : 1)
            .thenComparing(item -> normalize(item.recipe().getName()).contains(query) ? 0 : 1)
            .thenComparing(item -> item.recipe().getName())
            .thenComparing(item -> item.recipe().getId());
    }

    private String normalize(String value) {
        return value.toLowerCase(java.util.Locale.ROOT)
            .replaceAll("\\s+", "");
    }

    private record LoadedRecommendationData(
        List<IngredientVariant> ownedVariants,
        List<Recipe> recipes
    ) { }

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
            option.getIngredient().getIngredientVariant() == null
                ? option.getIngredient().getDisplayName()
                : option.getIngredient().getIngredientVariant().getName(),
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
