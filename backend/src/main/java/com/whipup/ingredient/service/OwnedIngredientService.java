package com.whipup.ingredient.service;

import com.whipup.generated.model.OwnedIngredient;
import com.whipup.generated.model.OwnedIngredientListResponse;
import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.exception.OwnedIngredientException;
import com.whipup.ingredient.repository.IngredientVariantRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import java.util.List;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OwnedIngredientService {

	private final IngredientVariantRepository ingredientVariantRepository;
	private final UserIngredientRepository userIngredientRepository;
	private final UserRepository userRepository;

	public OwnedIngredientService(
			IngredientVariantRepository ingredientVariantRepository,
			UserIngredientRepository userIngredientRepository,
			UserRepository userRepository
	) {
		this.ingredientVariantRepository = ingredientVariantRepository;
		this.userIngredientRepository = userIngredientRepository;
		this.userRepository = userRepository;
	}

	@Transactional(readOnly = true)
	public OwnedIngredientListResponse getOwnedIngredients(Long userId) {
		List<OwnedIngredient> items = userIngredientRepository
				.findAllByUser_IdOrderByIngredientVariant_NameAsc(userId)
				.stream()
				.map(this::toOwnedIngredient)
				.toList();

		return new OwnedIngredientListResponse(items);
	}

	@Transactional
	public OwnedIngredient addOwnedIngredient(Long userId, Long variantId) {
		IngredientVariant ingredientVariant = ingredientVariantRepository
				.findById(variantId)
				.orElseThrow(OwnedIngredientException::ingredientNotFound);

		if (userIngredientRepository.existsByUser_IdAndIngredientVariant_IdIn(
				userId,
				List.of(variantId)
		)) {
			throw OwnedIngredientException.alreadyExists();
		}

		User user = userRepository.getReferenceById(userId);
		UserIngredient userIngredient = UserIngredient.create(user, ingredientVariant);

		try {
			return toOwnedIngredient(
					userIngredientRepository.saveAndFlush(userIngredient)
			);
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
		IngredientVariant ingredientVariant = userIngredient.getIngredientVariant();

		return new OwnedIngredient(
				userIngredient.getId(),
				ingredientVariant.getId(),
				ingredientVariant.getName()
		);
	}
}
