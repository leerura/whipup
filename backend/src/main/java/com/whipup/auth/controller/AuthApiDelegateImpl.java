package com.whipup.auth.controller;

import com.whipup.auth.service.AuthService;
import com.whipup.auth.service.AccountDeletionService;
import com.whipup.common.security.CurrentUserProvider;
import com.whipup.auth.service.LoginResult;
import com.whipup.generated.api.AuthApiDelegate;
import com.whipup.generated.model.KakaoLoginRequest;
import com.whipup.generated.model.LoginResponse;
import com.whipup.generated.model.UserSummary;
import com.whipup.generated.model.TermsConsentRequest;
import com.whipup.user.repository.UserRepository;
import java.time.OffsetDateTime;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthApiDelegateImpl implements AuthApiDelegate {

	private final AuthService authService;
	private final AccountDeletionService accountDeletionService;
	private final CurrentUserProvider currentUserProvider;
	private final UserRepository userRepository;

	public AuthApiDelegateImpl(
			AuthService authService,
			AccountDeletionService accountDeletionService,
			CurrentUserProvider currentUserProvider,
			UserRepository userRepository
	) {
		this.authService = authService;
		this.accountDeletionService = accountDeletionService;
		this.currentUserProvider = currentUserProvider;
		this.userRepository = userRepository;
	}

	@Override
	public ResponseEntity<LoginResponse> loginWithKakao(KakaoLoginRequest request) {
		LoginResult result = authService.loginWithKakao(request.getKakaoAccessToken());

		LoginResponse response = new LoginResponse(
				result.accessToken(),
				new UserSummary(result.userId()),
				result.hasOwnedIngredients(),
				result.onboardingCompleted(),
				result.termsConsentRequired()
		);

		return ResponseEntity.ok(response);
	}

	@Override
	@Transactional
	public ResponseEntity<Void> acceptTermsConsent(TermsConsentRequest request) {
		if (!Boolean.TRUE.equals(request.getAge14OrOver())
				|| !"v1".equals(request.getTermsVersion())
				|| !"v1".equals(request.getPrivacyVersion())) {
			return ResponseEntity.badRequest().build();
		}

		userRepository.findById(currentUserProvider.getUserId())
				.orElseThrow()
				.acceptTerms(
					request.getTermsVersion(),
					request.getPrivacyVersion(),
					OffsetDateTime.now()
				);
		return ResponseEntity.noContent().build();
	}

	@Override
	public ResponseEntity<Void> deleteCurrentAccount() {
		accountDeletionService.deleteAccount(currentUserProvider.getUserId());
		return ResponseEntity.noContent().build();
	}
}
