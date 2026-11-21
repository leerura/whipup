package com.whipup.common.observability;

import com.whipup.generated.api.TelemetryApiDelegate;
import com.whipup.generated.model.HttpTimingRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class HttpTimingController implements TelemetryApiDelegate {
    private final WhipupMetrics metrics;

    public HttpTimingController(WhipupMetrics metrics) { this.metrics = metrics; }

    @Override
    public ResponseEntity<Void> recordHttpTiming(HttpTimingRequest timing) {
        // route, method, outcome are closed enums in the OpenAPI contract, so the
        // generated layer already rejects unknown values.
        metrics.recordDuration("whipup.client.http", timing.getDurationMs(),
            "route", timing.getRoute().getValue(),
            "method", timing.getMethod().getValue(),
            "outcome", timing.getOutcome().getValue());
        return ResponseEntity.noContent().build();
    }
}
