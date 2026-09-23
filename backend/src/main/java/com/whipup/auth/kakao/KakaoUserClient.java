package com.whipup.auth.kakao;

import com.whipup.auth.exception.KakaoAuthenticationException;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
public class KakaoUserClient {

	private final RestClient restClient;

	public KakaoUserClient(RestClient.Builder restClientBuilder) {
		this.restClient = restClientBuilder
				.baseUrl("https://kapi.kakao.com")
				.build();
	}

	public String getProviderUserId(String kakaoAccessToken) {
		if (!StringUtils.hasText(kakaoAccessToken)) {
			throw new KakaoAuthenticationException();
		}

		try {
			KakaoUserResponse response = restClient.get()
					.uri("/v2/user/me")
					.headers(headers -> headers.setBearerAuth(kakaoAccessToken))
					.retrieve()
					.body(KakaoUserResponse.class);

			if (response == null || response.id() == null) {
				throw new KakaoAuthenticationException();
			}

			return response.id().toString();
		} catch (RestClientException exception) {
			throw new KakaoAuthenticationException(exception);
		}
	}
}
