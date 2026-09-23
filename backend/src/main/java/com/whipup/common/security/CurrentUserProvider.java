package com.whipup.common.security;

import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

@Component
public class CurrentUserProvider {

	public Long getUserId() {
		Authentication authentication = SecurityContextHolder
				.getContext()
				.getAuthentication();

		if (authentication == null || !(authentication.getPrincipal() instanceof Jwt jwt)) {
			throw new AuthenticationCredentialsNotFoundException(
					"Authenticated user is unavailable"
			);
		}

		try {
			return Long.valueOf(jwt.getSubject());
		} catch (NumberFormatException exception) {
			throw new BadCredentialsException(
					"JWT subject is not a valid user id",
					exception
			);
		}
	}
}
