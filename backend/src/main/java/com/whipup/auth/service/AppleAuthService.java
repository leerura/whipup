package com.whipup.auth.service;

import com.whipup.auth.apple.AppleAuthenticationException;
import com.whipup.auth.apple.AppleIdentityTokenVerifier;
import com.whipup.auth.apple.AppleLoginUnavailableException;
import com.whipup.auth.apple.AppleProperties;
import com.whipup.auth.apple.AppleTokenCipher;
import com.whipup.auth.apple.AppleTokenClient;
import com.whipup.auth.domain.AuthProvider;
import com.whipup.auth.repository.UserAuthAccountRepository;
import com.whipup.user.domain.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AppleAuthService {

	private static final Logger log = LoggerFactory.getLogger(AppleAuthService.class);

	private final AppleProperties properties;
	private final AppleIdentityTokenVerifier verifier;
	private final AppleTokenClient tokenClient;
	private final AppleTokenCipher cipher;
	private final AuthAccountService authAccountService;
	private final AuthService authService;
	private final UserAuthAccountRepository authAccountRepository;

	public AppleAuthService(
			AppleProperties properties,
			AppleIdentityTokenVerifier verifier,
			AppleTokenClient tokenClient,
			AppleTokenCipher cipher,
			AuthAccountService authAccountService,
			AuthService authService,
			UserAuthAccountRepository authAccountRepository
	) {
		this.properties = properties;
		this.verifier = verifier;
		this.tokenClient = tokenClient;
		this.cipher = cipher;
		this.authAccountService = authAccountService;
		this.authService = authService;
		this.authAccountRepository = authAccountRepository;
	}

	public LoginResult loginWithApple(String identityToken, String authorizationCode, String nonce) {
		if (!properties.isConfigured()) {
			throw new AppleLoginUnavailableException("Apple login is not configured");
		}
		if (!StringUtils.hasText(authorizationCode)) {
			throw new AppleAuthenticationException("Apple authorization code is missing");
		}

		String subject = verifier.verify(identityToken, nonce);

		AppleTokenClient.TokenResponse tokens = tokenClient.exchangeAuthorizationCode(authorizationCode);
		if (!subject.equals(verifier.verifySubject(tokens.idToken()))) {
			throw new AppleAuthenticationException("Apple token subject mismatch");
		}

		String encryptedRefreshToken = StringUtils.hasText(tokens.refreshToken())
				? cipher.encrypt(tokens.refreshToken())
				: null;
		User user = authAccountService.findOrCreateAppleUser(subject, encryptedRefreshToken);
		return authService.toLoginResult(user);
	}

	/** Returns the user's decrypted Apple refresh token, or null when there is none to revoke. */
	public String findRefreshToken(Long userId) {
		try {
			return authAccountRepository.findByUser_IdAndProvider(userId, AuthProvider.APPLE)
					.map(account -> account.getAppleRefreshTokenEncrypted())
					.filter(StringUtils::hasText)
					.map(cipher::decrypt)
					.orElse(null);
		} catch (RuntimeException exception) {
			log.warn("Apple refresh token could not be read for revocation", exception);
			return null;
		}
	}

	/** Best-effort revoke after the account is deleted; failures never affect the caller. */
	public void revokeQuietly(String refreshToken) {
		if (!StringUtils.hasText(refreshToken) || !properties.isConfigured()) {
			return;
		}
		try {
			tokenClient.revokeRefreshToken(refreshToken);
		} catch (RuntimeException exception) {
			log.warn("Apple token revocation failed", exception);
		}
	}
}
