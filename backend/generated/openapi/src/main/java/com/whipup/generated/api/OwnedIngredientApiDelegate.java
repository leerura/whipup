package com.whipup.generated.api;

import com.whipup.generated.model.AddOwnedIngredientsRequest;
import com.whipup.generated.model.ErrorResponse;
import com.whipup.generated.model.OwnedIngredientListResponse;
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
 * A delegate to be called by the {@link OwnedIngredientApiController}}.
 * Implement this interface with a {@link org.springframework.stereotype.Service} annotated class.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public interface OwnedIngredientApiDelegate {

    default Optional<NativeWebRequest> getRequest() {
        return Optional.empty();
    }

    /**
     * POST /api/v1/me/ingredients
     *
     * @param addOwnedIngredientsRequest  (required)
     * @return Created (status code 201)
     *         or Invalid request (status code 400)
     *         or Resource not found (status code 404)
     *         or Request conflicts with current state (status code 409)
     *         or Authentication failed or missing (status code 401)
     * @see OwnedIngredientApi#addOwnedIngredients
     */
    default ResponseEntity<OwnedIngredientListResponse> addOwnedIngredients(AddOwnedIngredientsRequest addOwnedIngredientsRequest) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"items\" : [ { \"userIngredientId\" : 0, \"ingredientId\" : 6, \"displayName\" : \"displayName\" }, { \"userIngredientId\" : 0, \"ingredientId\" : 6, \"displayName\" : \"displayName\" } ] }";
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
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"code\" : \"code\", \"message\" : \"message\" }";
                    ApiUtil.setExampleResponse(request, "application/json", exampleString);
                    break;
                }
            }
        });
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);

    }

    /**
     * DELETE /api/v1/me/ingredients/{userIngredientId}
     *
     * @param userIngredientId  (required)
     * @return Deleted (status code 204)
     *         or Resource not found (status code 404)
     *         or Authentication failed or missing (status code 401)
     * @see OwnedIngredientApi#deleteOwnedIngredient
     */
    default ResponseEntity<Void> deleteOwnedIngredient(Long userIngredientId) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
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

    /**
     * GET /api/v1/me/ingredients
     *
     * @return Owned ingredients (status code 200)
     *         or Authentication failed or missing (status code 401)
     * @see OwnedIngredientApi#getOwnedIngredients
     */
    default ResponseEntity<OwnedIngredientListResponse> getOwnedIngredients() {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"items\" : [ { \"userIngredientId\" : 0, \"ingredientId\" : 6, \"displayName\" : \"displayName\" }, { \"userIngredientId\" : 0, \"ingredientId\" : 6, \"displayName\" : \"displayName\" } ] }";
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
