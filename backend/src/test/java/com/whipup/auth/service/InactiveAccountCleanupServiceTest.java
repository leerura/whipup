package com.whipup.auth.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.whipup.user.repository.UserRepository;
import java.time.OffsetDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;

class InactiveAccountCleanupServiceTest {

	@Test
	void deletesEveryInactiveAccountAndKeepsGoingAfterAFailure() {
		UserRepository users = mock(UserRepository.class);
		AccountDeletionService deletion = mock(AccountDeletionService.class);
		OffsetDateTime cutoff = OffsetDateTime.parse("2025-11-13T04:00:00+09:00");
		when(users.findInactiveUserIds(cutoff)).thenReturn(List.of(1L, 2L, 3L));
		doThrow(new IllegalStateException("boom")).when(deletion).deleteAccount(2L);

		int deleted = new InactiveAccountCleanupService(users, deletion)
				.deleteAccountsInactiveSince(cutoff);

		assertEquals(2, deleted);
		verify(deletion).deleteAccount(1L);
		verify(deletion).deleteAccount(2L);
		verify(deletion).deleteAccount(3L);
	}

	@Test
	void usesAOneYearInactivityLimit() {
		assertEquals(365, InactiveAccountCleanupService.INACTIVITY_LIMIT.toDays());
	}
}
