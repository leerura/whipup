package com.whipup.auth.service;

import com.whipup.auth.domain.AuthProvider;
import com.whipup.auth.domain.UserAuthAccount;
import com.whipup.auth.repository.UserAuthAccountRepository;
import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthAccountService {

	private final UserRepository userRepository;
	private final UserAuthAccountRepository authAccountRepository;

	public AuthAccountService(
			UserRepository userRepository,
			UserAuthAccountRepository authAccountRepository
	) {
		this.userRepository = userRepository;
		this.authAccountRepository = authAccountRepository;
	}

	@Transactional
	public User findOrCreateUser(AuthProvider provider, String providerUserId) {
		return authAccountRepository
				.findByProviderAndProviderUserId(provider, providerUserId)
				.map(UserAuthAccount::getUser)
				.orElseGet(() -> createUser(provider, providerUserId));
	}

	/** Finds or creates the Apple-linked user and stores the (already encrypted) refresh token. */
	@Transactional
	public User findOrCreateAppleUser(String providerUserId, String encryptedRefreshToken) {
		UserAuthAccount account = authAccountRepository
				.findByProviderAndProviderUserId(AuthProvider.APPLE, providerUserId)
				.orElseGet(() -> {
					User user = userRepository.save(User.create());
					return authAccountRepository.save(
							UserAuthAccount.link(user, AuthProvider.APPLE, providerUserId)
					);
				});
		if (encryptedRefreshToken != null) {
			account.setAppleRefreshTokenEncrypted(encryptedRefreshToken);
		}
		return account.getUser();
	}

	private User createUser(AuthProvider provider, String providerUserId) {
		User user = userRepository.save(User.create());

		authAccountRepository.save(
				UserAuthAccount.link(user, provider, providerUserId)
		);

		return user;
	}
}
