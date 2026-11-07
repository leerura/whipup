package com.whipup.auth.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.whipup.auth.domain.AuthProvider;
import com.whipup.auth.jwt.JwtTokenProvider;
import com.whipup.auth.kakao.KakaoUserClient;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import org.junit.jupiter.api.Test;

class AuthServiceOnboardingTest {

    private final KakaoUserClient kakaoUserClient = mock(KakaoUserClient.class);
    private final AuthAccountService authAccountService = mock(AuthAccountService.class);
    private final JwtTokenProvider jwtTokenProvider = mock(JwtTokenProvider.class);
    private final UserIngredientRepository userIngredientRepository = mock(UserIngredientRepository.class);

    @Test
    void loginSeparatesIncompleteAccountFromCompletedAccountWithNoIngredients() {
        User incompleteUser = mock(User.class);
        when(incompleteUser.getId()).thenReturn(1L);
        when(incompleteUser.isOnboardingCompleted()).thenReturn(false);
        when(authAccountService.findOrCreateUser(AuthProvider.KAKAO, "provider-user"))
            .thenReturn(incompleteUser);
        when(kakaoUserClient.getProviderUserId("kakao-token"))
            .thenReturn("provider-user");
        when(userIngredientRepository.existsByUser_Id(1L)).thenReturn(false);
        when(jwtTokenProvider.issueAccessToken(1L)).thenReturn("access-token");

        LoginResult incompleteResult = service().loginWithKakao("kakao-token");

        assertFalse(incompleteResult.hasOwnedIngredients());
        assertFalse(incompleteResult.onboardingCompleted());

        User completedUser = mock(User.class);
        when(completedUser.getId()).thenReturn(2L);
        when(completedUser.isOnboardingCompleted()).thenReturn(true);
        when(authAccountService.findOrCreateUser(AuthProvider.KAKAO, "provider-user"))
            .thenReturn(completedUser);
        when(userIngredientRepository.existsByUser_Id(2L)).thenReturn(false);
        when(jwtTokenProvider.issueAccessToken(2L)).thenReturn("access-token");

        LoginResult completedResult = service().loginWithKakao("kakao-token");

        assertFalse(completedResult.hasOwnedIngredients());
        assertTrue(completedResult.onboardingCompleted());
    }

    private AuthService service() {
        return new AuthService(
            kakaoUserClient,
            authAccountService,
            jwtTokenProvider,
            userIngredientRepository
        );
    }
}
