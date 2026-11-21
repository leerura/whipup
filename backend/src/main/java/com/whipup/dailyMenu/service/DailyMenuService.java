package com.whipup.dailyMenu.service;

import com.whipup.generated.model.RecommendationListResponse;
import com.whipup.common.observability.WhipupMetrics;
import io.micrometer.core.instrument.Timer;
import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeStatus;
import com.whipup.recipe.repository.RecipeRepository;
import com.whipup.recommendation.service.RecommendationService;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DailyMenuService {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    private final StringRedisTemplate redis;
    private final RecipeRepository recipeRepository;
    private final RecommendationService recommendationService;
    private final WhipupMetrics metrics;

    public DailyMenuService(
        StringRedisTemplate redis,
        RecipeRepository recipeRepository,
        RecommendationService recommendationService,
        WhipupMetrics metrics
    ) {
        this.redis = redis;
        this.recipeRepository = recipeRepository;
        this.recommendationService = recommendationService;
        this.metrics = metrics;
    }

    @Transactional(readOnly = true)
    public RecommendationListResponse get(Long userId) {
        Timer.Sample sample = metrics.start();
        try {
            List<Long> ids = redis.opsForZSet().reverseRange(key(userId), 0, -1)
                .stream().map(Long::valueOf).toList();
            RecommendationListResponse response;
            if (ids.isEmpty()) {
                response = new RecommendationListResponse(List.of());
            } else {
                List<Recipe> recipes = recipeRepository.findAllById(ids).stream()
                    .filter(recipe -> recipe.getStatus() == RecipeStatus.PUBLISHED)
                    .collect(Collectors.toMap(Recipe::getId, recipe -> recipe))
                    .values().stream().toList();
                List<Recipe> ordered = ids.stream()
                    .map(id -> recipes.stream().filter(recipe -> recipe.getId().equals(id)).findFirst().orElse(null))
                    .filter(java.util.Objects::nonNull).toList();
                response = recommendationService.toRecommendationItems(userId, ordered);
            }
            metrics.stop(sample, "whipup.daily_menu", "operation", "read", "result", "success");
            return response;
        } catch (DataAccessException | IllegalStateException exception) {
            metrics.stop(sample, "whipup.daily_menu", "operation", "read", "result", "unavailable");
            return new RecommendationListResponse(List.of());
        }
    }

    public void add(Long userId, Long recipeId) {
        Recipe recipe = recipeRepository.findByIdAndStatus(recipeId, RecipeStatus.PUBLISHED)
            .orElseThrow(com.whipup.recipe.exception.RecipeNotFoundException::new);
        Timer.Sample sample = metrics.start();
        try {
            String key = key(userId);
            redis.opsForZSet().addIfAbsent(key, recipe.getId().toString(), System.currentTimeMillis());
            redis.expireAt(key, nextMidnight().toInstant());
            metrics.stop(sample, "whipup.daily_menu", "operation", "add", "result", "success");
        } catch (DataAccessException exception) {
            metrics.stop(sample, "whipup.daily_menu", "operation", "add", "result", "unavailable");
            throw new DailyMenuUnavailableException(exception);
        }
    }

    public void remove(Long userId, Long recipeId) {
        Timer.Sample sample = metrics.start();
        try {
            redis.opsForZSet().remove(key(userId), recipeId.toString());
            metrics.stop(sample, "whipup.daily_menu", "operation", "remove", "result", "success");
        } catch (DataAccessException exception) {
            metrics.stop(sample, "whipup.daily_menu", "operation", "remove", "result", "unavailable");
            throw new DailyMenuUnavailableException(exception);
        }
    }

    private String key(Long userId) {
        return "daily-menu:" + userId + ":" + ZonedDateTime.now(KST).toLocalDate();
    }

    private ZonedDateTime nextMidnight() {
        return ZonedDateTime.now(KST).toLocalDate().plusDays(1).atStartOfDay(KST);
    }
}
