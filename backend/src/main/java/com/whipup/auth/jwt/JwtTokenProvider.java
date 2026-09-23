package com.whipup.auth.jwt;

import java.time.Instant;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.stereotype.Component;

@Component
public class JwtTokenProvider {

	private final JwtEncoder jwtEncoder;
	private final JwtProperties properties;

	public JwtTokenProvider(JwtEncoder jwtEncoder, JwtProperties properties) {
		this.jwtEncoder = jwtEncoder;
		this.properties = properties;
	}

	public String issueAccessToken(Long userId) {
		Instant issuedAt = Instant.now();

		JwtClaimsSet claims = JwtClaimsSet.builder()
				.subject(userId.toString())
				.issuedAt(issuedAt)
				.expiresAt(issuedAt.plus(properties.accessTokenExpiration()))
				.build();

		JwsHeader header = JwsHeader.with(MacAlgorithm.HS256)
				.type("JWT")
				.build();

		return jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
	}
}
