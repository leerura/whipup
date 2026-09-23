package com.whipup.recommendation.exception;

import org.springframework.http.HttpStatus;

public class RecommendationException extends RuntimeException {

    private final HttpStatus status;
    private final String code;

    private RecommendationException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public static RecommendationException invalidRequest() {
        return new RecommendationException(
            HttpStatus.BAD_REQUEST,
            "INVALID_REQUEST",
            "추천 조건이 올바르지 않습니다."
        );
    }

    public static RecommendationException noOwnedIngredients() {
        return new RecommendationException(
            HttpStatus.CONFLICT,
            "NO_OWNED_INGREDIENTS",
            "보유 재료를 먼저 등록해주세요."
        );
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getCode() {
        return code;
    }
}
