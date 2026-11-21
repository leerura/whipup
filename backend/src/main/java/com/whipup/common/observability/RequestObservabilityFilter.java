package com.whipup.common.observability;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestObservabilityFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestObservabilityFilter.class);
    private static final String REQUEST_ID = "X-Request-Id";

    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        String requestId = validUuid(request.getHeader(REQUEST_ID))
            ? request.getHeader(REQUEST_ID) : UUID.randomUUID().toString();
        long started = System.nanoTime();
        response.setHeader(REQUEST_ID, requestId);
        RequestTimingContext.start();
        MDC.put("requestId", requestId);
        try {
            filterChain.doFilter(request, response);
        } finally {
            String route = routeTemplate(request.getRequestURI());
            long totalMs = (System.nanoTime() - started) / 1_000_000;
            Map<String, Long> timings = RequestTimingContext.snapshot();
            MDC.put("method", request.getMethod());
            MDC.put("route", route);
            MDC.put("status", Integer.toString(response.getStatus()));
            MDC.put("totalMs", Long.toString(totalMs));
            try {
                String stages = timings.entrySet().stream()
                    .map(entry -> ",\"" + entry.getKey() + "\":" + entry.getValue())
                    .sorted()
                    .reduce("", String::concat);
                log.info(
                    "{\"event\":\"api.completed\",\"requestId\":\"{}\",\"route\":\"{}\",\"method\":\"{}\",\"status\":{},\"totalMs\":{}" + stages + "}",
                    requestId, route, request.getMethod(), response.getStatus(), totalMs
                );
            } finally {
                MDC.remove("requestId");
                MDC.remove("method");
                MDC.remove("route");
                MDC.remove("status");
                MDC.remove("totalMs");
                RequestTimingContext.clear();
            }
        }
    }

    private boolean validUuid(String value) {
        try {
            UUID.fromString(value);
            return true;
        } catch (IllegalArgumentException | NullPointerException ignored) {
            return false;
        }
    }

    private String routeTemplate(String uri) {
        return switch (uri) {
            case "/health", "/api/v1/auth/guest", "/api/v1/me",
                "/api/v1/me/terms-consent", "/api/v1/me/onboarding",
                "/api/v1/ingredients", "/api/v1/me/ingredients",
                "/api/v1/recipes/recommendations", "/api/v1/recipes/search",
                "/api/v1/me/daily-menu", "/api/v1/telemetry/http-timing",
                "/actuator/health", "/actuator/prometheus" -> uri;
            default -> dynamicRoute(uri);
        };
    }

    private String dynamicRoute(String uri) {
        if (uri.matches("/api/v1/recipes/\\d+")) return "/api/v1/recipes/{recipeId}";
        if (uri.matches("/api/v1/me/ingredients/\\d+")) return "/api/v1/me/ingredients/{userIngredientId}";
        if (uri.matches("/api/v1/me/daily-menu/\\d+")) return "/api/v1/me/daily-menu/{recipeId}";
        return "/unclassified";
    }
}
