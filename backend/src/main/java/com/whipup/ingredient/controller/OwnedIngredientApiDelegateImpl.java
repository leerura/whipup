package com.whipup.ingredient.controller;

import com.whipup.common.security.CurrentUserProvider;
import com.whipup.generated.api.OwnedIngredientApiDelegate;
import com.whipup.generated.model.AddOwnedIngredientsRequest;
import com.whipup.generated.model.OwnedIngredientListResponse;
import com.whipup.generated.model.OwnedIngredientSelection;
import com.whipup.ingredient.service.OwnedIngredientService;
import java.util.List;
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
	public ResponseEntity<OwnedIngredientListResponse> addOwnedIngredients(
			AddOwnedIngredientsRequest request
	) {
		Long userId = currentUserProvider.getUserId();
		List<Long> ingredientIds = request.getItems()
				.stream()
				.map(OwnedIngredientSelection::getIngredientId)
				.toList();

		OwnedIngredientListResponse response =
				ownedIngredientService.addOwnedIngredients(userId, ingredientIds);

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
