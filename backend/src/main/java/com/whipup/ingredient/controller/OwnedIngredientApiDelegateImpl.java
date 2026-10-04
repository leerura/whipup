package com.whipup.ingredient.controller;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.generated.api.OwnedIngredientApiDelegate;
import com.whipup.generated.model.AddOwnedIngredientRequest;
import com.whipup.generated.model.OwnedIngredient;
import com.whipup.generated.model.OwnedIngredientListResponse;
import com.whipup.ingredient.service.OwnedIngredientService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class OwnedIngredientApiDelegateImpl implements OwnedIngredientApiDelegate {

	private final CurrentUserProvider currentUserProvider;
	private final OwnedIngredientService ownedIngredientService;

	public OwnedIngredientApiDelegateImpl(
			CurrentUserProvider currentUserProvider,
			OwnedIngredientService ownedIngredientService
	) {
		this.currentUserProvider = currentUserProvider;
		this.ownedIngredientService = ownedIngredientService;
	}

	@Override
	public ResponseEntity<OwnedIngredientListResponse> getOwnedIngredients() {
		Long userId = currentUserProvider.getUserId();

		return ResponseEntity.ok(
				ownedIngredientService.getOwnedIngredients(userId)
		);
	}

	@Override
	public ResponseEntity<OwnedIngredient> addOwnedIngredient(
			AddOwnedIngredientRequest request
	) {
		Long userId = currentUserProvider.getUserId();
		OwnedIngredient response = ownedIngredientService.addOwnedIngredient(
				userId,
				request.getVariantId()
		);

		return ResponseEntity
				.status(HttpStatus.CREATED)
				.body(response);
	}

	@Override
	public ResponseEntity<Void> deleteOwnedIngredient(Long userIngredientId) {
		Long userId = currentUserProvider.getUserId();
		ownedIngredientService.deleteOwnedIngredient(userId, userIngredientId);

		return ResponseEntity.noContent().build();
	}
}
