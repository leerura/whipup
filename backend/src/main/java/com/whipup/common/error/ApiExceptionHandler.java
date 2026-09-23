package com.whipup.common.error;

import com.whipup.auth.exception.KakaoAuthenticationException;
import com.whipup.generated.model.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {

	@ExceptionHandler(KakaoAuthenticationException.class)
	public ResponseEntity<ErrorResponse> handleKakaoAuthenticationException() {
		ErrorResponse response = new ErrorResponse(
				"KAKAO_AUTH_FAILED",
				"카카오 인증에 실패했습니다."
		);

		return ResponseEntity
				.status(HttpStatus.UNAUTHORIZED)
				.body(response);
	}

	@ExceptionHandler(AuthenticationException.class)
	public ResponseEntity<ErrorResponse> handleAuthenticationException() {
		ErrorResponse response = new ErrorResponse(
				"UNAUTHORIZED",
				"인증이 필요합니다."
		);

		return ResponseEntity
				.status(HttpStatus.UNAUTHORIZED)
				.body(response);
	}
}
