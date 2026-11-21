package com.whipup.recipe.controller;

import com.whipup.generated.api.RecipeApiDelegate;
import com.whipup.generated.model.RecipeDetailResponse;
import com.whipup.generated.model.RecommendationListResponse;
import com.whipup.generated.model.RecipeSearchScope;
import com.whipup.common.security.CurrentUserProvider;
import com.whipup.recipe.service.RecipeService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class RecipeApiDelegateImpl implements RecipeApiDelegate {

    private final RecipeService recipeService;
    private final com.whipup.recommendation.service.RecommendationService recommendationService;
    private final CurrentUserProvider currentUserProvider;

    public RecipeApiDelegateImpl(
        RecipeService recipeService,
        com.whipup.recommendation.service.RecommendationService recommendationService,
        CurrentUserProvider currentUserProvider
    ) {
        this.recipeService = recipeService;
        this.recommendationService = recommendationService;
        this.currentUserProvider = currentUserProvider;
    }

    @Override
    public ResponseEntity<RecipeDetailResponse> getRecipeDetail(Long recipeId) {
        return ResponseEntity.ok(recipeService.getRecipeDetail(recipeId));
    }

    @Override
    public ResponseEntity<RecommendationListResponse> searchRecipes(
        RecipeSearchScope scope,
        String query
    ) {
        return ResponseEntity.ok(recommendationService.searchRecipes(
            currentUserProvider.getUserId(), scope, query
        ));
    }
}
