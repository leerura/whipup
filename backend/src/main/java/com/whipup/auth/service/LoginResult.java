package com.whipup.auth.service;

public record LoginResult(
		String accessToken,
		Long userId,
		boolean hasOwnedIngredients
) {
}
