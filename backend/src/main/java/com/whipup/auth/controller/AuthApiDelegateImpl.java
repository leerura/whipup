package com.whipup.auth.controller;

import com.whipup.auth.service.AuthService;
import com.whipup.auth.service.AccountDeletionService;
import com.whipup.common.security.CurrentUserProvider;
import com.whipup.auth.service.LoginResult;
import com.whipup.generated.api.AuthApiDelegate;
import com.whipup.generated.model.KakaoLoginRequest;
import com.whipup.generated.model.LoginResponse;
import com.whipup.generated.model.UserSummary;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class AuthApiDelegateImpl implements AuthApiDelegate {

	private final AuthService authService;
	private final AccountDeletionService accountDeletionService;
	private final CurrentUserProvider currentUserProvider;

	public AuthApiDelegateImpl(
			AuthService authService,
			AccountDeletionService accountDeletionService,
			CurrentUserProvider currentUserProvider
	) {
		this.authService = authService;
		this.accountDeletionService = accountDeletionService;
		this.currentUserProvider = currentUserProvider;
	}

	@Override
	public ResponseEntity<LoginResponse> loginWithKakao(KakaoLoginRequest request) {
		LoginResult result = authService.loginWithKakao(request.getKakaoAccessToken());

		LoginResponse response = new LoginResponse(
				result.accessToken(),
				new UserSummary(result.userId()),
				result.hasOwnedIngredients(),
				result.onboardingCompleted()
		);

		return ResponseEntity.ok(response);
	}

	@Override
	public ResponseEntity<Void> deleteCurrentAccount() {
		accountDeletionService.deleteAccount(currentUserProvider.getUserId());
		return ResponseEntity.noContent().build();
	}
}
