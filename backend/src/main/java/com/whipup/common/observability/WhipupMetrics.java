package com.whipup.common.observability;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import java.util.function.Supplier;
import org.springframework.stereotype.Component;

@Component
public class WhipupMetrics {
    private final MeterRegistry registry;

    public WhipupMetrics(MeterRegistry registry) {
        this.registry = registry;
    }

    public <T> T record(String name, Supplier<T> action, String... tags) {
        Timer.Sample sample = Timer.start(registry);
        try {
            return action.get();
        } finally {
            long durationNanos = sample.stop(timer(name, tags));
            RequestTimingContext.record(name, durationNanos);
        }
    }

    public void record(String name, Runnable action, String... tags) {
        record(name, () -> { action.run(); return null; }, tags);
    }

    public void recordDuration(String name, long durationMs, String... tags) {
        timer(name, tags).record(java.time.Duration.ofMillis(durationMs));
    }

    public Timer.Sample start() {
        return Timer.start(registry);
    }

    public void stop(Timer.Sample sample, String name, String... tags) {
        long durationNanos = sample.stop(timer(name, tags));
        RequestTimingContext.record(name, durationNanos);
    }

    private Timer timer(String name, String... tags) {
        return Timer.builder(name)
            .publishPercentileHistogram()
            .tags(tags)
            .register(registry);
    }
}
