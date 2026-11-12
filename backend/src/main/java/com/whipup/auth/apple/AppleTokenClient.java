package com.whipup.auth.apple;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestClientException;

/** Calls Apple's token exchange and revoke endpoints. */
@Component
public class AppleTokenClient {

	private final RestClient restClient;
	private final AppleProperties properties;
	private final AppleClientSecretFactory clientSecretFactory;

	public AppleTokenClient(
			RestClient.Builder restClientBuilder,
			AppleProperties properties,
			AppleClientSecretFactory clientSecretFactory
	) {
		this.restClient = restClientBuilder.baseUrl("https://appleid.apple.com").build();
		this.properties = properties;
		this.clientSecretFactory = clientSecretFactory;
	}

	public TokenResponse exchangeAuthorizationCode(String authorizationCode) {
		MultiValueMap<String, String> form = baseForm();
		form.add("grant_type", "authorization_code");
		form.add("code", authorizationCode);
		try {
			TokenResponse response = restClient.post()
					.uri("/auth/token")
					.contentType(MediaType.APPLICATION_FORM_URLENCODED)
					.body(form)
					.retrieve()
					.body(TokenResponse.class);
			if (response == null || response.idToken() == null) {
				throw new AppleAuthenticationException("Apple token response was empty");
			}
			return response;
		} catch (RestClientResponseException exception) {
			// 4xx from Apple means the code is invalid/expired; 5xx means Apple is unavailable.
			if (exception.getStatusCode().is4xxClientError()) {
				throw new AppleAuthenticationException("Apple rejected the authorization code", exception);
			}
			throw new AppleLoginUnavailableException("Apple token endpoint failed", exception);
		} catch (RestClientException exception) {
			throw new AppleLoginUnavailableException("Apple token endpoint is unreachable", exception);
		}
	}

	public void revokeRefreshToken(String refreshToken) {
		MultiValueMap<String, String> form = baseForm();
		form.add("token", refreshToken);
		form.add("token_type_hint", "refresh_token");
		restClient.post()
				.uri("/auth/revoke")
				.contentType(MediaType.APPLICATION_FORM_URLENCODED)
				.body(form)
				.retrieve()
				.toBodilessEntity();
	}

	private MultiValueMap<String, String> baseForm() {
		MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
		form.add("client_id", properties.clientId());
		form.add("client_secret", clientSecretFactory.create());
		return form;
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record TokenResponse(
			@JsonProperty("id_token") String idToken,
			@JsonProperty("refresh_token") String refreshToken
	) {
	}
}
