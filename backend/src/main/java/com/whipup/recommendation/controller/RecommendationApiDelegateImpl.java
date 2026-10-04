package com.whipup.recommendation.controller;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.generated.api.RecommendationApiDelegate;
import com.whipup.generated.model.RecommendationListResponse;
import com.whipup.generated.model.RecommendationMode;
import com.whipup.recommendation.service.RecommendationService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class RecommendationApiDelegateImpl implements RecommendationApiDelegate {

    private final CurrentUserProvider currentUserProvider;
    private final RecommendationService recommendationService;

    public RecommendationApiDelegateImpl(
        CurrentUserProvider currentUserProvider,
        RecommendationService recommendationService
    ) {
        this.currentUserProvider = currentUserProvider;
        this.recommendationService = recommendationService;
    }

    @Override
    public ResponseEntity<RecommendationListResponse> getRecipeRecommendations(
        RecommendationMode mode
    ) {
        Long userId = currentUserProvider.getUserId();

        return ResponseEntity.ok(
            recommendationService.getRecipeRecommendations(userId, mode)
        );
    }
}
