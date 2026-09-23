package com.whipup.generated.api;

import com.whipup.generated.model.ErrorResponse;
import com.whipup.generated.model.RecipeDetailResponse;
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
 * A delegate to be called by the {@link RecipeApiController}}.
 * Implement this interface with a {@link org.springframework.stereotype.Service} annotated class.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public interface RecipeApiDelegate {

    default Optional<NativeWebRequest> getRequest() {
        return Optional.empty();
    }

    /**
     * GET /api/v1/recipes/{recipeId}
     *
     * @param recipeId  (required)
     * @return Recipe detail (status code 200)
     *         or Authentication failed or missing (status code 401)
     *         or Resource not found (status code 404)
     * @see RecipeApi#getRecipeDetail
     */
    default ResponseEntity<RecipeDetailResponse> getRecipeDetail(Long recipeId) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"recipeId\" : 0, \"name\" : \"name\", \"shortsReference\" : \"https://openapi-generator.tech\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 0, \"ingredients\" : [ { \"recipeIngredientId\" : 1, \"ingredientId\" : 5, \"displayName\" : \"displayName\", \"amount\" : \"amount\", \"unit\" : \"unit\", \"displayOrder\" : 1, \"owned\" : true }, { \"recipeIngredientId\" : 1, \"ingredientId\" : 5, \"displayName\" : \"displayName\", \"amount\" : \"amount\", \"unit\" : \"unit\", \"displayOrder\" : 1, \"owned\" : true } ], \"steps\" : [ { \"order\" : 1, \"content\" : \"content\" }, { \"order\" : 1, \"content\" : \"content\" } ] }";
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
