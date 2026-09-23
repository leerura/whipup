package com.whipup.generated.api;

import com.whipup.generated.model.ErrorResponse;
import org.springframework.lang.Nullable;
import com.whipup.generated.model.RecommendationPage;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.constraints.*;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import jakarta.annotation.Generated;

/**
 * A delegate to be called by the {@link RecommendationApiController}}.
 * Implement this interface with a {@link org.springframework.stereotype.Service} annotated class.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public interface RecommendationApiDelegate {

    default Optional<NativeWebRequest> getRequest() {
        return Optional.empty();
    }

    /**
     * GET /api/v1/recommendations
     *
     * @param missingCount  (required)
     * @param page  (optional, default to 0)
     * @param size  (optional, default to 30)
     * @return Recommendations (status code 200)
     *         or Invalid request (status code 400)
     *         or Authentication failed or missing (status code 401)
     *         or Request conflicts with current state (status code 409)
     * @see RecommendationApi#getRecommendations
     */
    default ResponseEntity<RecommendationPage> getRecommendations(Integer missingCount,
        Integer page,
        Integer size) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"items\" : [ { \"recipeId\" : 0, \"name\" : \"name\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 6, \"missingIngredients\" : [ { \"ingredientId\" : 1, \"name\" : \"name\" }, { \"ingredientId\" : 1, \"name\" : \"name\" } ] }, { \"recipeId\" : 0, \"name\" : \"name\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 6, \"missingIngredients\" : [ { \"ingredientId\" : 1, \"name\" : \"name\" }, { \"ingredientId\" : 1, \"name\" : \"name\" } ] } ], \"page\" : 5, \"size\" : 5, \"hasNext\" : true }";
                    ApiUtil.setExampleResponse(request, "application/json", exampleString);
                    break;
                }
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"code\" : \"code\", \"message\" : \"message\" }";
                    ApiUtil.setExampleResponse(request, "application/json", exampleString);
                    break;
                }
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"code\" : \"code\", \"message\" : \"message\" }";
                    ApiUtil.setExampleResponse(request, "application/json", exampleString);
                    break;
                }
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"code\" : \"code\", \"message\" : \"message\" }";
                    ApiUtil.setExampleResponse(request, "application/json", exampleString);
                    break;
                }
            }
        });
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);

    }

}
