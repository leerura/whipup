package com.whipup.common.observability;

import java.util.HashMap;
import java.util.Map;

final class RequestTimingContext {
    private static final ThreadLocal<Map<String, Long>> DURATIONS = new ThreadLocal<>();

    private RequestTimingContext() { }

    static void start() { DURATIONS.set(new HashMap<>()); }

    static void record(String metric, long nanos) {
        Map<String, Long> timings = DURATIONS.get();
        if (timings == null) return;
        String field = switch (metric) {
            case "whipup.recommendation.load" -> "loadMs";
            case "whipup.recommendation.match" -> "matchMs";
            case "whipup.recommendation.project" -> "projectMs";
            default -> null;
        };
        if (field != null) timings.merge(field, nanos / 1_000_000, Long::sum);
    }

    static Map<String, Long> snapshot() {
        Map<String, Long> timings = DURATIONS.get();
        return timings == null ? Map.of() : Map.copyOf(timings);
    }

    static void clear() { DURATIONS.remove(); }
}
