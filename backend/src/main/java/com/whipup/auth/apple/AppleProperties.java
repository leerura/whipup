package com.whipup.auth.apple;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.StringUtils;

/**
 * Sign in with Apple credentials. Every value is optional so the application
 * starts without them; Apple login then fails with APPLE_LOGIN_UNAVAILABLE.
 */
@ConfigurationProperties("auth.apple")
public record AppleProperties(
		String clientId,
		String teamId,
		String keyId,
		String privateKey,
		String tokenEncryptionKey
) {

	public boolean isConfigured() {
		return StringUtils.hasText(clientId)
				&& StringUtils.hasText(teamId)
				&& StringUtils.hasText(keyId)
				&& StringUtils.hasText(privateKey)
				&& StringUtils.hasText(tokenEncryptionKey);
	}
}
