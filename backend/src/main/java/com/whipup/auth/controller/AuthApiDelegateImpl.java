package com.whipup.auth.controller;

import com.whipup.auth.service.AppleAuthService;
import com.whipup.auth.service.AuthService;
import com.whipup.auth.service.AccountDeletionService;
import com.whipup.common.security.CurrentUserProvider;
import com.whipup.auth.service.LoginResult;
import com.whipup.generated.api.AuthApiDelegate;
import com.whipup.generated.model.AppleLoginRequest;
import com.whipup.generated.model.CurrentAccountResponse;
import com.whipup.generated.model.KakaoLoginRequest;
import com.whipup.generated.model.LoginResponse;
import com.whipup.generated.model.UserSummary;
import com.whipup.generated.model.TermsConsentRequest;
import com.whipup.user.repository.UserRepository;
import java.time.OffsetDateTime;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthApiDelegateImpl implements AuthApiDelegate {

	private final AuthService authService;
	private final AppleAuthService appleAuthService;
	private final AccountDeletionService accountDeletionService;
	private final CurrentUserProvider currentUserProvider;
	private final UserRepository userRepository;

	public AuthApiDelegateImpl(
			AuthService authService,
			AppleAuthService appleAuthService,
			AccountDeletionService accountDeletionService,
			CurrentUserProvider currentUserProvider,
			UserRepository userRepository
	) {
		this.authService = authService;
		this.appleAuthService = appleAuthService;
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
	public ResponseEntity<CurrentAccountResponse> getCurrentAccount() {
		return userRepository.findById(currentUserProvider.getUserId())
				.map(authService::toAccountState)
				.map(state -> ResponseEntity.ok(new CurrentAccountResponse(
						new UserSummary(state.userId()),
						state.hasOwnedIngredients(),
						state.onboardingCompleted(),
						state.termsConsentRequired()
				)))
				// A valid token whose user was deleted is treated as unauthenticated.
				.orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
	}

	@Override
	public ResponseEntity<LoginResponse> loginWithApple(AppleLoginRequest request) {
		LoginResult result = appleAuthService.loginWithApple(
				request.getIdentityToken(),
				request.getAuthorizationCode(),
				request.getNonce()
		);

		return ResponseEntity.ok(new LoginResponse(
				result.accessToken(),
				new UserSummary(result.userId()),
				result.hasOwnedIngredients(),
				result.onboardingCompleted(),
				result.termsConsentRequired()
		));
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
		Long userId = currentUserProvider.getUserId();
		// The Apple token must be read before the account rows are deleted, and is
		// revoked only after the deletion has committed.
		String appleRefreshToken = appleAuthService.findRefreshToken(userId);
		accountDeletionService.deleteAccount(userId);
		appleAuthService.revokeQuietly(appleRefreshToken);
		return ResponseEntity.noContent().build();
	}
}
