package com.whipup.common.observability;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.Set;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Validated
@RequestMapping("/api/v1/telemetry")
public class HttpTimingController {
    private static final Set<String> ROUTES = Set.of(
        "/api/v1/auth/kakao", "/api/v1/me", "/api/v1/me/terms-consent",
        "/api/v1/me/onboarding",
        "/api/v1/recipes/recommendations", "/api/v1/recipes/search",
        "/api/v1/recipes/{recipeId}", "/api/v1/me/daily-menu",
        "/api/v1/me/daily-menu/{recipeId}", "/api/v1/me/ingredients",
        "/api/v1/me/ingredients/{userIngredientId}", "/api/v1/ingredients"
    );
    private static final Set<String> METHODS = Set.of("GET", "POST", "DELETE");
    private static final Set<String> OUTCOMES = Set.of("SUCCESS", "CLIENT_ERROR", "SERVER_ERROR", "NETWORK_ERROR");
    private final WhipupMetrics metrics;

    public HttpTimingController(WhipupMetrics metrics) { this.metrics = metrics; }

    @PostMapping("/http-timing")
    public ResponseEntity<Void> record(@Valid @RequestBody HttpTiming timing) {
        if (!ROUTES.contains(timing.route()) || !METHODS.contains(timing.method())
            || !OUTCOMES.contains(timing.outcome())) {
            return ResponseEntity.badRequest().build();
        }
        metrics.recordDuration("whipup.client.http", timing.durationMs(),
            "route", timing.route(), "method", timing.method(), "outcome", timing.outcome());
        return ResponseEntity.noContent().build();
    }

    public record HttpTiming(
        @NotBlank String route,
        @NotBlank String method,
        @NotBlank String outcome,
        @Min(0) @Max(60000) long durationMs
    ) { }
}
