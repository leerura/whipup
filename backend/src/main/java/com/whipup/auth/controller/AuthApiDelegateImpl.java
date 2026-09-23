package com.whipup.auth.controller;

import com.whipup.auth.service.AuthService;
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

	public AuthApiDelegateImpl(AuthService authService) {
		this.authService = authService;
	}

	@Override
	public ResponseEntity<LoginResponse> loginWithKakao(KakaoLoginRequest request) {
		LoginResult result = authService.loginWithKakao(request.getKakaoAccessToken());

		LoginResponse response = new LoginResponse(
				result.accessToken(),
				new UserSummary(result.userId()),
				result.hasOwnedIngredients()
		);

		return ResponseEntity.ok(response);
	}
}
