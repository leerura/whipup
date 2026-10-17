package com.whipup.recipe.service;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.generated.model.DetailIngredientDisplay;
import com.whipup.generated.model.DetailRequirement;
import com.whipup.generated.model.DetailRequirementOption;
import com.whipup.generated.model.IngredientMatch;
import com.whipup.generated.model.MissingDetailRequirement;
import com.whipup.generated.model.RecipeDetailResponse;
import com.whipup.generated.model.SatisfiedDetailRequirement;
import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeIngredient;
import com.whipup.recipe.domain.RecipeRequirementOption;
import com.whipup.recipe.domain.RecipeRequirementSubstitute;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.exception.RecipeNotFoundException;
import com.whipup.recipe.repository.RecipeRepository;
import com.whipup.recipe.service.RecipeMatchResult.IngredientMatchResult;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RecipeService {

    private static final String YOUTUBE_THUMBNAIL_URL =
        "https://img.youtube.com/vi/%s/hqdefault.jpg";

    private final RecipeRepository recipeRepository;
    private final UserIngredientRepository userIngredientRepository;
    private final CurrentUserProvider currentUserProvider;
    private final RecipeMatchService recipeMatchService;

    public RecipeService(
        RecipeRepository recipeRepository,
        UserIngredientRepository userIngredientRepository,
        CurrentUserProvider currentUserProvider,
        RecipeMatchService recipeMatchService
    ) {
        this.recipeRepository = recipeRepository;
        this.userIngredientRepository = userIngredientRepository;
        this.currentUserProvider = currentUserProvider;
        this.recipeMatchService = recipeMatchService;
    }

    @Transactional(readOnly = true)
    public RecipeDetailResponse getRecipeDetail(Long recipeId) {
        Long userId = currentUserProvider.getUserId();
        Recipe recipe = recipeRepository
            .findByIdAndStatus(recipeId, RecipeStatus.PUBLISHED)
            .orElseThrow(RecipeNotFoundException::new);

        List<IngredientVariant> ownedVariants = userIngredientRepository
            .findAllByUser_IdOrderByIngredientVariant_NameAsc(userId)
            .stream()
            .map(UserIngredient::getIngredientVariant)
            .toList();

        RecipeMatchResult matchResult = recipeMatchService.match(
            recipe,
            ownedVariants
        );

        List<DetailRequirement> requirements = matchResult.requirements()
            .stream()
            .map(this::toDetailRequirement)
            .toList();

        List<DetailIngredientDisplay> optionalIngredients = recipe
            .getIngredients()
            .stream()
            .filter(RecipeIngredient::isOptional)
            .sorted(Comparator.comparingInt(RecipeIngredient::getDisplayOrder))
            .map(this::toIngredientDisplay)
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

        URI shortsReference = URI.create(recipe.getShortsReference());
        URI thumbnailUrl = URI.create(YOUTUBE_THUMBNAIL_URL.formatted(
            extractYoutubeVideoId(shortsReference)
        ));

        return new RecipeDetailResponse(
            recipe.getId(),
            recipe.getName(),
            shortsReference,
            thumbnailUrl,
            matchResult.missingCount(),
            requirements,
            optionalIngredients,
            steps
        );
    }

    private DetailRequirement toDetailRequirement(
        RecipeMatchResult.RequirementResult result
    ) {
        List<DetailRequirementOption> options = result.requirement()
            .getOptions()
            .stream()
            .sorted(Comparator.comparingInt(
                RecipeRequirementOption::getDisplayOrder
            ))
            .map(this::toDetailRequirementOption)
            .toList();

        if (result.satisfied()) {
            List<IngredientMatch> matches = result.matches()
                .stream()
                .map(this::toIngredientMatch)
                .toList();

            return new SatisfiedDetailRequirement(
                SatisfiedDetailRequirement.StatusEnum.SATISFIED,
                options,
                matches
            );
        }

        return new MissingDetailRequirement(
            MissingDetailRequirement.StatusEnum.MISSING,
            options
        );
    }

    private DetailRequirementOption toDetailRequirementOption(
        RecipeRequirementOption option
    ) {
        RecipeIngredient ingredient = option.getIngredient();
        List<DetailIngredientDisplay> substitutes = option.getSubstitutes()
            .stream()
            .sorted(Comparator.comparingInt(
                RecipeRequirementSubstitute::getDisplayOrder
            ))
            .map(RecipeRequirementSubstitute::getIngredient)
            .map(this::toIngredientDisplay)
            .toList();

        return new DetailRequirementOption(
            ingredient.getDisplayName(),
            ingredient.getRawText(),
            substitutes
        )
            .amount(ingredient.getAmount())
            .unit(ingredient.getUnit());
    }

    private DetailIngredientDisplay toIngredientDisplay(
        RecipeIngredient ingredient
    ) {
        return new DetailIngredientDisplay(
            ingredient.getDisplayName(),
            ingredient.getRawText()
        )
            .amount(ingredient.getAmount())
            .unit(ingredient.getUnit());
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
