package com.whipup.ingredient.controller;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.generated.api.OnboardingApiDelegate;
import com.whipup.generated.model.OnboardingRequest;
import com.whipup.ingredient.service.OwnedIngredientService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class OnboardingApiDelegateImpl implements OnboardingApiDelegate {

    private final CurrentUserProvider currentUserProvider;
    private final OwnedIngredientService ownedIngredientService;

    public OnboardingApiDelegateImpl(
        CurrentUserProvider currentUserProvider,
        OwnedIngredientService ownedIngredientService
    ) {
        this.currentUserProvider = currentUserProvider;
        this.ownedIngredientService = ownedIngredientService;
    }

    @Override
    public ResponseEntity<Void> completeOnboarding(OnboardingRequest request) {
        ownedIngredientService.completeOnboarding(
            currentUserProvider.getUserId(),
            request.getVariantIds()
        );
        return ResponseEntity.noContent().build();
    }
}
