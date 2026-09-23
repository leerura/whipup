package com.whipup.auth.service;

import com.whipup.auth.domain.AuthProvider;
import com.whipup.auth.jwt.JwtTokenProvider;
import com.whipup.auth.kakao.KakaoUserClient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

	private final KakaoUserClient kakaoUserClient;
	private final AuthAccountService authAccountService;
	private final JwtTokenProvider jwtTokenProvider;
	private final UserIngredientRepository userIngredientRepository;

	public AuthService(
			KakaoUserClient kakaoUserClient,
			AuthAccountService authAccountService,
			JwtTokenProvider jwtTokenProvider,
			UserIngredientRepository userIngredientRepository
	) {
		this.kakaoUserClient = kakaoUserClient;
		this.authAccountService = authAccountService;
		this.jwtTokenProvider = jwtTokenProvider;
		this.userIngredientRepository = userIngredientRepository;
	}

	public LoginResult loginWithKakao(String kakaoAccessToken) {
		String providerUserId = kakaoUserClient.getProviderUserId(kakaoAccessToken);

		User user = authAccountService.findOrCreateUser(
				AuthProvider.KAKAO,
				providerUserId
		);

		boolean hasOwnedIngredients = userIngredientRepository.existsByUser_Id(user.getId());
		String accessToken = jwtTokenProvider.issueAccessToken(user.getId());

		return new LoginResult(accessToken, user.getId(), hasOwnedIngredients);
	}
}
