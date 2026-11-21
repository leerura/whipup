package com.whipup.auth.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.whipup.auth.jwt.JwtTokenProvider;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import org.junit.jupiter.api.Test;

class AuthServiceOnboardingTest {

    private final JwtTokenProvider jwtTokenProvider = mock(JwtTokenProvider.class);
    private final UserIngredientRepository userIngredientRepository = mock(UserIngredientRepository.class);
    private final UserRepository userRepository = mock(UserRepository.class);

    @Test
    void loginSeparatesIncompleteAccountFromCompletedAccountWithNoIngredients() {
        User incompleteUser = mock(User.class);
        when(incompleteUser.getId()).thenReturn(1L);
        when(incompleteUser.isOnboardingCompleted()).thenReturn(false);
        when(userIngredientRepository.existsByUser_Id(1L)).thenReturn(false);
        when(jwtTokenProvider.issueAccessToken(1L)).thenReturn("access-token");

        LoginResult incompleteResult = service().toLoginResult(incompleteUser);

        assertFalse(incompleteResult.hasOwnedIngredients());
        assertFalse(incompleteResult.onboardingCompleted());

        User completedUser = mock(User.class);
        when(completedUser.getId()).thenReturn(2L);
        when(completedUser.isOnboardingCompleted()).thenReturn(true);
        when(userIngredientRepository.existsByUser_Id(2L)).thenReturn(false);
        when(jwtTokenProvider.issueAccessToken(2L)).thenReturn("access-token");

        LoginResult completedResult = service().toLoginResult(completedUser);

        assertFalse(completedResult.hasOwnedIngredients());
        assertTrue(completedResult.onboardingCompleted());
    }

    @Test
    void guestSessionCreatesAFreshAccountThatMustAcceptTerms() {
        User guest = User.create();
        when(userRepository.save(org.mockito.ArgumentMatchers.any(User.class))).thenReturn(guest);
        when(jwtTokenProvider.issueAccessToken(guest.getId())).thenReturn("guest-token");

        LoginResult result = service().startGuestSession();

        assertEquals("guest-token", result.accessToken());
        assertFalse(result.hasOwnedIngredients());
        assertFalse(result.onboardingCompleted());
        assertTrue(result.termsConsentRequired());
    }

    private AuthService service() {
        return new AuthService(jwtTokenProvider, userIngredientRepository, userRepository);
    }
}
