package com.whipup.ingredient.exception;

import org.springframework.http.HttpStatus;

public class OwnedIngredientException extends RuntimeException {

	private final HttpStatus status;
	private final String code;

	private OwnedIngredientException(
			HttpStatus status,
			String code,
			String message
	) {
		super(message);
		this.status = status;
		this.code = code;
	}

	public static OwnedIngredientException invalidRequest() {
		return new OwnedIngredientException(
				HttpStatus.BAD_REQUEST,
				"INVALID_REQUEST",
				"요청에 중복된 재료가 있습니다."
		);
	}

	public static OwnedIngredientException ingredientNotFound() {
		return new OwnedIngredientException(
				HttpStatus.NOT_FOUND,
				"INGREDIENT_NOT_FOUND",
				"존재하지 않는 재료입니다."
		);
	}

	public static OwnedIngredientException alreadyExists() {
		return new OwnedIngredientException(
				HttpStatus.CONFLICT,
				"OWNED_INGREDIENT_ALREADY_EXISTS",
				"이미 보유 중인 재료입니다."
		);
	}

	public static OwnedIngredientException userIngredientNotFound() {
		return new OwnedIngredientException(
				HttpStatus.NOT_FOUND,
				"USER_INGREDIENT_NOT_FOUND",
				"보유 재료를 찾을 수 없습니다."
		);
	}

	public HttpStatus getStatus() {
		return status;
	}

	public String getCode() {
		return code;
	}
}
