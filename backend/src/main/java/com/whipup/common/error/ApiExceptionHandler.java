package com.whipup.common.error;

import com.whipup.auth.exception.KakaoAuthenticationException;
import com.whipup.generated.model.ErrorResponse;
import com.whipup.ingredient.exception.OwnedIngredientException;
import com.whipup.recipe.exception.RecipeNotFoundException;
import com.whipup.recommendation.exception.RecommendationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ErrorResponse> handleMethodArgumentNotValidException() {
		ErrorResponse response = new ErrorResponse(
				"INVALID_REQUEST",
				"하나 이상의 재료를 선택해주세요."
		);

		return ResponseEntity
				.status(HttpStatus.BAD_REQUEST)
				.body(response);
	}

	@ExceptionHandler(OwnedIngredientException.class)
	public ResponseEntity<ErrorResponse> handleOwnedIngredientException(
			OwnedIngredientException exception
	) {
		ErrorResponse response = new ErrorResponse(
				exception.getCode(),
				exception.getMessage()
		);

		return ResponseEntity
				.status(exception.getStatus())
				.body(response);
	}

	@ExceptionHandler(RecommendationException.class)
	public ResponseEntity<ErrorResponse> handleRecommendationException(
			RecommendationException exception
	) {
		ErrorResponse response = new ErrorResponse(
				exception.getCode(),
				exception.getMessage()
		);

		return ResponseEntity
				.status(exception.getStatus())
				.body(response);
	}

	@ExceptionHandler(KakaoAuthenticationException.class)
	public ResponseEntity<ErrorResponse> handleKakaoAuthenticationException() {
		ErrorResponse response = new ErrorResponse(
				"KAKAO_AUTH_FAILED",
				"카카오 인증에 실패했습니다."
		);

		return ResponseEntity
				.status(HttpStatus.UNAUTHORIZED)
				.body(response);
	}

	@ExceptionHandler(RecipeNotFoundException.class)
	public ResponseEntity<ErrorResponse> handleRecipeNotFoundException(
			RecipeNotFoundException exception
	) {
		ErrorResponse response = new ErrorResponse(
				"RECIPE_NOT_FOUND",
				exception.getMessage()
		);

		return ResponseEntity
				.status(HttpStatus.NOT_FOUND)
				.body(response);
	}

	@ExceptionHandler(AuthenticationException.class)
	public ResponseEntity<ErrorResponse> handleAuthenticationException() {
		ErrorResponse response = new ErrorResponse(
				"UNAUTHORIZED",
				"인증이 필요합니다."
		);

		return ResponseEntity
				.status(HttpStatus.UNAUTHORIZED)
				.body(response);
	}
}
