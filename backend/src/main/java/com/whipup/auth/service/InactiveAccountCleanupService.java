package com.whipup.auth.service;

import com.whipup.user.repository.UserRepository;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

/** Deletes guest accounts that have not been used for a year (docs/v4/product). */
@Service
public class InactiveAccountCleanupService {

	static final Duration INACTIVITY_LIMIT = Duration.ofDays(365);

	private static final Logger log = LoggerFactory.getLogger(InactiveAccountCleanupService.class);

	private final UserRepository userRepository;
	private final AccountDeletionService accountDeletionService;

	public InactiveAccountCleanupService(
			UserRepository userRepository,
			AccountDeletionService accountDeletionService
	) {
		this.userRepository = userRepository;
		this.accountDeletionService = accountDeletionService;
	}

	@Scheduled(cron = "${whipup.account-cleanup.cron:0 0 4 * * *}", zone = "Asia/Seoul")
	public void deleteInactiveAccounts() {
		int deleted = deleteAccountsInactiveSince(OffsetDateTime.now().minus(INACTIVITY_LIMIT));
		log.info("Inactive account cleanup deleted {} account(s)", deleted);
	}

	/** Deletes each inactive account in its own transaction; one failure does not stop the rest. */
	int deleteAccountsInactiveSince(OffsetDateTime cutoff) {
		List<Long> userIds = userRepository.findInactiveUserIds(cutoff);
		int deleted = 0;
		for (Long userId : userIds) {
			try {
				accountDeletionService.deleteAccount(userId);
				deleted++;
			} catch (RuntimeException exception) {
				// AccountDeletionService already logs the failure; keep cleaning the rest.
			}
		}
		return deleted;
	}
}
