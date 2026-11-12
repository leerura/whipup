package com.whipup.auth.apple;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.List;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimValidator;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/** Verifies the Apple identity token and its nonce, and returns Apple's stable user id (sub). */
@Component
public class AppleIdentityTokenVerifier {

	private static final String JWKS_URI = "https://appleid.apple.com/auth/keys";

	private final AppleProperties properties;
	private volatile JwtDecoder decoder;

	public AppleIdentityTokenVerifier(AppleProperties properties) {
		this.properties = properties;
	}

	public String verify(String identityToken, String rawNonce) {
		if (!StringUtils.hasText(identityToken) || !StringUtils.hasText(rawNonce)) {
			throw new AppleAuthenticationException("Apple identity token or nonce is missing");
		}
		Jwt jwt = decode(identityToken);
		Object nonceClaim = jwt.getClaims().get("nonce");
		if (!(nonceClaim instanceof String nonce) || !nonce.equals(sha256Hex(rawNonce))) {
			throw new AppleAuthenticationException("Apple identity token nonce does not match");
		}
		String subject = jwt.getSubject();
		if (!StringUtils.hasText(subject)) {
			throw new AppleAuthenticationException("Apple identity token has no subject");
		}
		return subject;
	}

	/** Used for the id_token Apple returns from the code exchange; the nonce is not echoed there. */
	public String verifySubject(String idToken) {
		String subject = decode(idToken).getSubject();
		if (!StringUtils.hasText(subject)) {
			throw new AppleAuthenticationException("Apple id token has no subject");
		}
		return subject;
	}

	private Jwt decode(String token) {
		try {
			return decoder().decode(token);
		} catch (JwtException exception) {
			throw new AppleAuthenticationException("Apple token verification failed", exception);
		}
	}

	private JwtDecoder decoder() {
		JwtDecoder current = decoder;
		if (current == null) {
			synchronized (this) {
				current = decoder;
				if (current == null) {
					if (!StringUtils.hasText(properties.clientId())) {
						throw new AppleLoginUnavailableException("Apple client id is not configured");
					}
					NimbusJwtDecoder nimbus = NimbusJwtDecoder.withJwkSetUri(JWKS_URI)
							.jwsAlgorithm(SignatureAlgorithm.RS256)
							.build();
					OAuth2TokenValidator<Jwt> validator = new DelegatingOAuth2TokenValidator<>(
							JwtValidators.createDefaultWithIssuer(AppleClientSecretFactory.APPLE_ISSUER),
							new JwtClaimValidator<List<String>>(
									"aud",
									audience -> audience != null && audience.contains(properties.clientId())
							)
					);
					nimbus.setJwtValidator(validator);
					decoder = current = nimbus;
				}
			}
		}
		return current;
	}

	static String sha256Hex(String value) {
		try {
			return HexFormat.of().formatHex(
					MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8))
			);
		} catch (NoSuchAlgorithmException exception) {
			throw new IllegalStateException(exception);
		}
	}
}
