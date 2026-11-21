package com.whipup.dailyMenu.controller;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.dailyMenu.service.DailyMenuService;
import com.whipup.generated.api.DailyMenuApiDelegate;
import com.whipup.generated.model.DailyMenuRequest;
import com.whipup.generated.model.RecommendationListResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class DailyMenuApiDelegateImpl implements DailyMenuApiDelegate {

    private final CurrentUserProvider currentUserProvider;
    private final DailyMenuService dailyMenuService;

    public DailyMenuApiDelegateImpl(
        CurrentUserProvider currentUserProvider,
        DailyMenuService dailyMenuService
    ) {
        this.currentUserProvider = currentUserProvider;
        this.dailyMenuService = dailyMenuService;
    }

    @Override
    public ResponseEntity<RecommendationListResponse> getDailyMenu() {
        return ResponseEntity.ok(dailyMenuService.get(currentUserProvider.getUserId()));
    }

    @Override
    public ResponseEntity<Void> addDailyMenu(DailyMenuRequest request) {
        dailyMenuService.add(currentUserProvider.getUserId(), request.getRecipeId());
        return ResponseEntity.noContent().build();
    }

    @Override
    public ResponseEntity<Void> removeDailyMenu(Long recipeId) {
        dailyMenuService.remove(currentUserProvider.getUserId(), recipeId);
        return ResponseEntity.noContent().build();
    }
}
