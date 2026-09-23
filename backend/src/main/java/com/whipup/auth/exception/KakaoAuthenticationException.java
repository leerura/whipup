package com.whipup.auth.exception;

public class KakaoAuthenticationException extends RuntimeException {

	public KakaoAuthenticationException() {
		super("Kakao authentication failed");
	}

	public KakaoAuthenticationException(Throwable cause) {
		super("Kakao authentication failed", cause);
	}
}
