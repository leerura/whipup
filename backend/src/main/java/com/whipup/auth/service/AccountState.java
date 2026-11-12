package com.whipup.auth.service;

public record AccountState(
		Long userId,
		boolean hasOwnedIngredients,
		boolean onboardingCompleted,
		boolean termsConsentRequired
) {
}
