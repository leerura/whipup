package com.whipup.auth.apple;

public class AppleLoginUnavailableException extends RuntimeException {

	public AppleLoginUnavailableException(String message) {
		super(message);
	}

	public AppleLoginUnavailableException(String message, Throwable cause) {
		super(message, cause);
	}
}
