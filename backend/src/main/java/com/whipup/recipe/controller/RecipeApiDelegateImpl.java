package com.whipup.recipe.controller;

import com.whipup.generated.api.RecipeApiDelegate;
import com.whipup.generated.model.RecipeDetailResponse;
import com.whipup.recipe.service.RecipeService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class RecipeApiDelegateImpl implements RecipeApiDelegate {

    private final RecipeService recipeService;

    public RecipeApiDelegateImpl(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    @Override
    public ResponseEntity<RecipeDetailResponse> getRecipeDetail(Long recipeId) {
        return ResponseEntity.ok(recipeService.getRecipeDetail(recipeId));
    }
}
