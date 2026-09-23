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
 * A delegate to be called by the {@link RecipesApiController}}.
 * Implement this interface with a {@link org.springframework.stereotype.Service} annotated class.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-09-23T01:37:49.076375542Z[Etc/UTC]", comments = "Generator version: 7.19.0")
public interface RecipesApiDelegate {

    default Optional<NativeWebRequest> getRequest() {
        return Optional.empty();
    }

    /**
     * GET /recipes/{recipeId}
     *
     * @param recipeId  (required)
     * @return Recipe detail (status code 200)
     *         or Authentication failed or missing (status code 401)
     *         or Resource not found (status code 404)
     * @see RecipesApi#getRecipeDetail
     */
    default ResponseEntity<RecipeDetailResponse> getRecipeDetail(Long recipeId) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"missingCount\" : 0, \"shortsReference\" : \"https://openapi-generator.tech\", \"name\" : \"name\", \"ingredients\" : [ { \"ingredientId\" : 5, \"amount\" : \"amount\", \"unit\" : \"unit\", \"displayName\" : \"displayName\", \"owned\" : true, \"displayOrder\" : 1, \"recipeIngredientId\" : 1 }, { \"ingredientId\" : 5, \"amount\" : \"amount\", \"unit\" : \"unit\", \"displayName\" : \"displayName\", \"owned\" : true, \"displayOrder\" : 1, \"recipeIngredientId\" : 1 } ], \"steps\" : [ { \"content\" : \"content\", \"order\" : 1 }, { \"content\" : \"content\", \"order\" : 1 } ], \"recipeId\" : 0, \"thumbnailUrl\" : \"https://openapi-generator.tech\" }";
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
