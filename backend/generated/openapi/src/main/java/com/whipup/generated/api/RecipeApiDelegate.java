package com.whipup.generated.api;

import com.whipup.generated.model.ErrorResponse;
import com.whipup.generated.model.RecipeDetailResponse;
import com.whipup.generated.model.RecipeSearchScope;
import com.whipup.generated.model.RecommendationListResponse;
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
     * @return Recipe detail projected with current user matching state (status code 200)
     *         or Authentication failed or missing (status code 401)
     *         or Resource not found (status code 404)
     * @see RecipeApi#getRecipeDetail
     */
    default ResponseEntity<RecipeDetailResponse> getRecipeDetail(Long recipeId) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"recipeId\" : 0, \"name\" : \"name\", \"shortsReference\" : \"https://openapi-generator.tech\", \"sourceTitle\" : \"sourceTitle\", \"sourceChannelName\" : \"sourceChannelName\", \"sourceChannelId\" : \"sourceChannelId\", \"sourceChannelThumbnailUrl\" : \"https://openapi-generator.tech\", \"sourceMetadataFetchedAt\" : \"2000-01-23T04:56:07.000+00:00\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 0, \"requirements\" : [ { \"status\" : \"SATISFIED\", \"options\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\", \"substitutes\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" } ], \"addableVariants\" : [ { \"variantId\" : 0, \"name\" : \"name\" }, { \"variantId\" : 0, \"name\" : \"name\" } ] }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\", \"substitutes\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" } ], \"addableVariants\" : [ { \"variantId\" : 0, \"name\" : \"name\" }, { \"variantId\" : 0, \"name\" : \"name\" } ] } ], \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] }, { \"status\" : \"SATISFIED\", \"options\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\", \"substitutes\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" } ], \"addableVariants\" : [ { \"variantId\" : 0, \"name\" : \"name\" }, { \"variantId\" : 0, \"name\" : \"name\" } ] }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\", \"substitutes\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" } ], \"addableVariants\" : [ { \"variantId\" : 0, \"name\" : \"name\" }, { \"variantId\" : 0, \"name\" : \"name\" } ] } ], \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] } ], \"optionalIngredients\" : [ { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" }, { \"displayName\" : \"displayName\", \"rawText\" : \"rawText\", \"amount\" : \"amount\", \"unit\" : \"unit\" } ], \"steps\" : [ { \"order\" : 1, \"content\" : \"content\" }, { \"order\" : 1, \"content\" : \"content\" } ] }";
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
     * GET /api/v1/recipes/search
     *
     * @param scope  (required)
     * @param query  (required)
     * @return Published recipes matching the selected scope and query (status code 200)
     *         or Invalid request (status code 400)
     *         or Authentication failed or missing (status code 401)
     * @see RecipeApi#searchRecipes
     */
    default ResponseEntity<RecommendationListResponse> searchRecipes(RecipeSearchScope scope,
        String query) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"items\" : [ { \"recipeId\" : 0, \"name\" : \"name\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 0, \"requirementResults\" : [ { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] }, { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] } ], \"sourceChannelName\" : \"sourceChannelName\", \"sourceChannelThumbnailUrl\" : \"https://openapi-generator.tech\" }, { \"recipeId\" : 0, \"name\" : \"name\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 0, \"requirementResults\" : [ { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] }, { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] } ], \"sourceChannelName\" : \"sourceChannelName\", \"sourceChannelThumbnailUrl\" : \"https://openapi-generator.tech\" } ] }";
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
