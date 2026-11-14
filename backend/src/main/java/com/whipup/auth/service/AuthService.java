package com.whipup.auth.service;

import com.whipup.auth.jwt.JwtTokenProvider;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
	private static final String CURRENT_TERMS_VERSION = "v1";
	private static final String CURRENT_PRIVACY_VERSION = "v1";

	private final JwtTokenProvider jwtTokenProvider;
	private final UserIngredientRepository userIngredientRepository;
	private final UserRepository userRepository;

	public AuthService(
			JwtTokenProvider jwtTokenProvider,
			UserIngredientRepository userIngredientRepository,
			UserRepository userRepository
	) {
		this.jwtTokenProvider = jwtTokenProvider;
		this.userIngredientRepository = userIngredientRepository;
		this.userRepository = userRepository;
	}

	/** Creates a new account that holds no personal information. */
	public LoginResult startGuestSession() {
		return toLoginResult(userRepository.save(User.create()));
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
