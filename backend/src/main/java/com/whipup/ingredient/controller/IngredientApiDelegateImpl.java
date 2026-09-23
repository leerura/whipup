package com.whipup.ingredient.controller;

import com.whipup.generated.api.IngredientApiDelegate;
import com.whipup.generated.model.IngredientOptionListResponse;
import com.whipup.ingredient.service.IngredientService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class IngredientApiDelegateImpl implements IngredientApiDelegate {

    private final IngredientService ingredientService;

    public IngredientApiDelegateImpl(IngredientService ingredientService) {
        this.ingredientService = ingredientService;
    }

    @Override
    public ResponseEntity<IngredientOptionListResponse> getIngredientOptions() {
        return ResponseEntity.ok(ingredientService.getIngredientOptions());
    }
}
