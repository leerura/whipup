package com.whipup.common.health;

import com.whipup.generated.api.HealthApiDelegate;
import com.whipup.generated.model.HealthResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class HealthApiDelegateImpl implements HealthApiDelegate {

	@Override
	public ResponseEntity<HealthResponse> getHealth() {
		return ResponseEntity.ok(new HealthResponse("UP"));
	}
}
