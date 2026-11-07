package com.whipup.auth.service;

import com.whipup.auth.repository.UserAuthAccountRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class AccountDeletionService {

	private static final Logger log = LoggerFactory.getLogger(AccountDeletionService.class);

	private final UserAuthAccountRepository userAuthAccountRepository;
	private final UserIngredientRepository userIngredientRepository;
	private final UserRepository userRepository;

	public AccountDeletionService(
			UserAuthAccountRepository userAuthAccountRepository,
			UserIngredientRepository userIngredientRepository,
			UserRepository userRepository
	) {
		this.userAuthAccountRepository = userAuthAccountRepository;
		this.userIngredientRepository = userIngredientRepository;
		this.userRepository = userRepository;
	}

	@Transactional
	public void deleteAccount(Long userId) {
		try {
			// Delete rows owning the user before the user row itself. Shared catalog,
			// recipe, and recipe-history data are deliberately never touched here.
			userAuthAccountRepository.deleteAllByUser_Id(userId);
			userIngredientRepository.deleteAllByUser_Id(userId);
			userRepository.deleteById(userId);
		} catch (RuntimeException exception) {
			log.error("Account deletion failed for userId={}; transaction will roll back", userId, exception);
			throw exception;
		}
	}
}
