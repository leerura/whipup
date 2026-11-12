package com.whipup.auth.apple;

public class AppleAuthenticationException extends RuntimeException {

	public AppleAuthenticationException(String message) {
		super(message);
	}

	public AppleAuthenticationException(String message, Throwable cause) {
		super(message, cause);
	}
}
