package com.whipup.auth.apple;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.crypto.ECDSASigner;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.interfaces.ECPrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;
import org.springframework.stereotype.Component;

/** Builds the ES256 client_secret JWT Apple requires on token and revoke calls. */
@Component
public class AppleClientSecretFactory {

	static final String APPLE_ISSUER = "https://appleid.apple.com";

	private final AppleProperties properties;

	public AppleClientSecretFactory(AppleProperties properties) {
		this.properties = properties;
	}

	public String create() {
		try {
			Instant now = Instant.now();
			JWTClaimsSet claims = new JWTClaimsSet.Builder()
					.issuer(properties.teamId())
					.subject(properties.clientId())
					.audience(APPLE_ISSUER)
					.issueTime(Date.from(now))
					.expirationTime(Date.from(now.plusSeconds(300)))
					.build();
			SignedJWT jwt = new SignedJWT(
					new JWSHeader.Builder(JWSAlgorithm.ES256).keyID(properties.keyId()).build(),
					claims
			);
			jwt.sign(new ECDSASigner(privateKey()));
			return jwt.serialize();
		} catch (JOSEException | GeneralSecurityException | RuntimeException exception) {
			throw new AppleLoginUnavailableException("Apple client secret could not be created", exception);
		}
	}

	private ECPrivateKey privateKey() throws GeneralSecurityException {
		String pem = properties.privateKey()
				.replace("\\n", "\n")
				.replaceAll("-----(BEGIN|END) PRIVATE KEY-----", "")
				.replaceAll("\\s", "");
		byte[] der = Base64.getDecoder().decode(pem);
		return (ECPrivateKey) KeyFactory.getInstance("EC").generatePrivate(new PKCS8EncodedKeySpec(der));
	}
}
