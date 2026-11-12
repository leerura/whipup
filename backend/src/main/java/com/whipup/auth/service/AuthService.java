package com.whipup.auth.service;

import com.whipup.auth.domain.AuthProvider;
import com.whipup.auth.jwt.JwtTokenProvider;
import com.whipup.auth.kakao.KakaoUserClient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
	private static final String CURRENT_TERMS_VERSION = "v1";
	private static final String CURRENT_PRIVACY_VERSION = "v1";

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

		return toLoginResult(user);
	}

	/** Current account state for token re-entry. */
	public AccountState toAccountState(User user) {
		return new AccountState(
				user.getId(),
				userIngredientRepository.existsByUser_Id(user.getId()),
				user.isOnboardingCompleted(),
				user.requiresTermsConsent(CURRENT_TERMS_VERSION, CURRENT_PRIVACY_VERSION)
		);
	}

	public LoginResult toLoginResult(User user) {
		boolean hasOwnedIngredients = userIngredientRepository.existsByUser_Id(user.getId());
		String accessToken = jwtTokenProvider.issueAccessToken(user.getId());

		return new LoginResult(
				accessToken,
				user.getId(),
				hasOwnedIngredients,
				user.isOnboardingCompleted(),
				user.requiresTermsConsent(CURRENT_TERMS_VERSION, CURRENT_PRIVACY_VERSION)
		);
	}
}
