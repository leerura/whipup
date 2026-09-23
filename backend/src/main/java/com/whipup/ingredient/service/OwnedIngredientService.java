package com.whipup.ingredient.service;

import com.whipup.generated.model.OwnedIngredient;
import com.whipup.generated.model.OwnedIngredientListResponse;
import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.exception.OwnedIngredientException;
import com.whipup.ingredient.repository.IngredientRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OwnedIngredientService {

	private final IngredientRepository ingredientRepository;
	private final UserIngredientRepository userIngredientRepository;
	private final UserRepository userRepository;

	public OwnedIngredientService(
			IngredientRepository ingredientRepository,
			UserIngredientRepository userIngredientRepository,
			UserRepository userRepository
	) {
		this.ingredientRepository = ingredientRepository;
		this.userIngredientRepository = userIngredientRepository;
		this.userRepository = userRepository;
	}

	@Transactional(readOnly = true)
	public OwnedIngredientListResponse getOwnedIngredients(Long userId) {
		List<OwnedIngredient> items = userIngredientRepository
				.findAllByUser_IdOrderByIngredient_CanonicalNameAsc(userId)
				.stream()
				.map(this::toOwnedIngredient)
				.toList();

		return new OwnedIngredientListResponse(items);
	}

	@Transactional
	public OwnedIngredientListResponse addOwnedIngredients(
			Long userId,
			List<Long> ingredientIds
	) {
		if (new HashSet<>(ingredientIds).size() != ingredientIds.size()) {
			throw OwnedIngredientException.invalidRequest();
		}

		List<Ingredient> ingredients = ingredientRepository.findAllById(ingredientIds);
		if (ingredients.size() != ingredientIds.size()) {
			throw OwnedIngredientException.ingredientNotFound();
		}

		if (userIngredientRepository.existsByUser_IdAndIngredient_IdIn(
				userId,
				ingredientIds
		)) {
			throw OwnedIngredientException.alreadyExists();
		}

		Map<Long, Ingredient> ingredientsById = new HashMap<>();
		for (Ingredient ingredient : ingredients) {
			ingredientsById.put(ingredient.getId(), ingredient);
		}

		User user = userRepository.getReferenceById(userId);
		List<UserIngredient> userIngredients = ingredientIds.stream()
				.map(ingredientId -> UserIngredient.create(
						user,
						ingredientsById.get(ingredientId)
				))
				.toList();

		try {
			List<OwnedIngredient> items = userIngredientRepository
					.saveAllAndFlush(userIngredients)
					.stream()
					.map(this::toOwnedIngredient)
					.toList();

			return new OwnedIngredientListResponse(items);
		} catch (DataIntegrityViolationException exception) {
			throw OwnedIngredientException.alreadyExists();
		}
	}

	@Transactional
	public void deleteOwnedIngredient(Long userId, Long userIngredientId) {
		UserIngredient userIngredient = userIngredientRepository
				.findByIdAndUser_Id(userIngredientId, userId)
				.orElseThrow(OwnedIngredientException::userIngredientNotFound);

		userIngredientRepository.delete(userIngredient);
	}

	private OwnedIngredient toOwnedIngredient(UserIngredient userIngredient) {
		Ingredient ingredient = userIngredient.getIngredient();

		return new OwnedIngredient(
				userIngredient.getId(),
				ingredient.getId(),
				ingredient.getCanonicalName()
		);
	}
}
