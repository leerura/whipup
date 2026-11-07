package com.whipup.auth.service;

import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.whipup.auth.repository.UserAuthAccountRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;

class AccountDeletionServiceTest {

	@Test
	void deletesUserOwnedRowsBeforeTheUserRow() {
		UserAuthAccountRepository authAccounts = mock(UserAuthAccountRepository.class);
		UserIngredientRepository ingredients = mock(UserIngredientRepository.class);
		UserRepository users = mock(UserRepository.class);
		AccountDeletionService service = new AccountDeletionService(authAccounts, ingredients, users);

		service.deleteAccount(42L);

		InOrder order = inOrder(authAccounts, ingredients, users);
		order.verify(authAccounts).deleteAllByUser_Id(42L);
		order.verify(ingredients).deleteAllByUser_Id(42L);
		order.verify(users).deleteById(42L);
		verify(users).deleteById(42L);
	}
}
