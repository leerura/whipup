package com.whipup.auth.controller;

import com.whipup.auth.service.AuthService;
import com.whipup.auth.service.AccountDeletionService;
import com.whipup.common.security.CurrentUserProvider;
import com.whipup.auth.service.LoginResult;
import com.whipup.generated.api.AuthApiDelegate;
import com.whipup.generated.model.CurrentAccountResponse;
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
	public ResponseEntity<LoginResponse> startGuestSession() {
		LoginResult result = authService.startGuestSession();

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
	public ResponseEntity<CurrentAccountResponse> getCurrentAccount() {
		return userRepository.findById(currentUserProvider.getUserId())
				.map(user -> {
					// Opening the app counts as use for the 1-year inactivity rule.
					user.markActive(OffsetDateTime.now());
					return authService.toAccountState(user);
				})
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
