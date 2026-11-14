package com.whipup.auth.repository;

import com.whipup.auth.domain.AuthProvider;
import com.whipup.auth.domain.UserAuthAccount;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAuthAccountRepository extends JpaRepository<UserAuthAccount, Long> {

	void deleteAllByUser_Id(Long userId);

	Optional<UserAuthAccount> findByProviderAndProviderUserId(
			AuthProvider provider,
			String providerUserId
	);
}
