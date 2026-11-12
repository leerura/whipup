package com.whipup.auth.apple;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.nimbusds.jose.crypto.ECDSAVerifier;
import com.nimbusds.jwt.SignedJWT;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECGenParameterSpec;
import java.util.Base64;
import org.junit.jupiter.api.Test;

class AppleAuthComponentsTest {

	private static final String ENCRYPTION_KEY =
			Base64.getEncoder().encodeToString(new byte[32]);

	@Test
	void cipherRoundTripsAndUsesRandomIv() {
		AppleTokenCipher cipher = new AppleTokenCipher(
				new AppleProperties("id", "team", "key", "pem", ENCRYPTION_KEY)
		);

		String first = cipher.encrypt("refresh-token");
		String second = cipher.encrypt("refresh-token");

		assertNotEquals(first, second);
		assertFalse(first.contains("refresh-token"));
		assertEquals("refresh-token", cipher.decrypt(first));
	}

	@Test
	void cipherRejectsMissingOrShortKey() {
		AppleTokenCipher missing = new AppleTokenCipher(new AppleProperties("id", "t", "k", "p", ""));
		AppleTokenCipher shortKey = new AppleTokenCipher(
				new AppleProperties("id", "t", "k", "p", Base64.getEncoder().encodeToString(new byte[16]))
		);

		assertThrows(AppleLoginUnavailableException.class, () -> missing.encrypt("x"));
		assertThrows(AppleLoginUnavailableException.class, () -> shortKey.encrypt("x"));
	}

	@Test
	void clientSecretIsEs256JwtWithAppleClaims() throws Exception {
		KeyPairGenerator generator = KeyPairGenerator.getInstance("EC");
		generator.initialize(new ECGenParameterSpec("secp256r1"));
		KeyPair keyPair = generator.generateKeyPair();
		String pem = "-----BEGIN PRIVATE KEY-----\n"
				+ Base64.getMimeEncoder(64, "\n".getBytes()).encodeToString(keyPair.getPrivate().getEncoded())
				+ "\n-----END PRIVATE KEY-----";
		AppleClientSecretFactory factory = new AppleClientSecretFactory(
				new AppleProperties("com.example.app", "TEAM123", "KEY456", pem.replace("\n", "\\n"), ENCRYPTION_KEY)
		);

		SignedJWT jwt = SignedJWT.parse(factory.create());

		assertEquals("ES256", jwt.getHeader().getAlgorithm().getName());
		assertEquals("KEY456", jwt.getHeader().getKeyID());
		assertEquals("TEAM123", jwt.getJWTClaimsSet().getIssuer());
		assertEquals("com.example.app", jwt.getJWTClaimsSet().getSubject());
		assertEquals("https://appleid.apple.com", jwt.getJWTClaimsSet().getAudience().get(0));
		assertTrue(jwt.verify(new ECDSAVerifier((ECPublicKey) keyPair.getPublic())));
	}

	@Test
	void verifierRejectsMissingTokenOrNonceBeforeAnyNetworkCall() {
		AppleIdentityTokenVerifier verifier = new AppleIdentityTokenVerifier(
				new AppleProperties("com.example.app", "t", "k", "p", ENCRYPTION_KEY)
		);

		assertThrows(AppleAuthenticationException.class, () -> verifier.verify("", "nonce"));
		assertThrows(AppleAuthenticationException.class, () -> verifier.verify("token", " "));
	}

	@Test
	void nonceDigestIsLowercaseSha256Hex() {
		assertEquals(
				"2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824",
				AppleIdentityTokenVerifier.sha256Hex("hello")
		);
	}

	@Test
	void propertiesReportConfigurationState() {
		assertFalse(new AppleProperties("", "", "", "", "").isConfigured());
		assertFalse(new AppleProperties("id", "t", "k", "p", null).isConfigured());
		assertTrue(new AppleProperties("id", "t", "k", "p", "e").isConfigured());
	}
}
