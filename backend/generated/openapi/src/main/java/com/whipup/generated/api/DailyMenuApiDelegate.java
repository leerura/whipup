package com.whipup.generated.api;

import com.whipup.generated.model.DailyMenuRequest;
import com.whipup.generated.model.ErrorResponse;
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
 * A delegate to be called by the {@link DailyMenuApiController}}.
 * Implement this interface with a {@link org.springframework.stereotype.Service} annotated class.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public interface DailyMenuApiDelegate {

    default Optional<NativeWebRequest> getRequest() {
        return Optional.empty();
    }

    /**
     * POST /api/v1/me/daily-menu
     *
     * @param dailyMenuRequest  (required)
     * @return Added (or already present) (status code 204)
     *         or Resource not found (status code 404)
     *         or Daily menu storage unavailable (status code 503)
     *         or Authentication failed or missing (status code 401)
     * @see DailyMenuApi#addDailyMenu
     */
    default ResponseEntity<Void> addDailyMenu(DailyMenuRequest dailyMenuRequest) {
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
     * GET /api/v1/me/daily-menu
     *
     * @return Today&#39;s menu in most-recently-added order (status code 200)
     *         or Authentication failed or missing (status code 401)
     * @see DailyMenuApi#getDailyMenu
     */
    default ResponseEntity<RecommendationListResponse> getDailyMenu() {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"items\" : [ { \"recipeId\" : 0, \"name\" : \"name\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 0, \"requirementResults\" : [ { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] }, { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] } ] }, { \"recipeId\" : 0, \"name\" : \"name\", \"thumbnailUrl\" : \"https://openapi-generator.tech\", \"missingCount\" : 0, \"requirementResults\" : [ { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] }, { \"status\" : \"SATISFIED\", \"matches\" : [ { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" }, { \"type\" : \"DIRECT\", \"requiredName\" : \"requiredName\", \"ownedName\" : \"ownedName\" } ] } ] } ] }";
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
     * DELETE /api/v1/me/daily-menu/{recipeId}
     *
     * @param recipeId  (required)
     * @return Removed (or already absent) (status code 204)
     *         or Daily menu storage unavailable (status code 503)
     *         or Authentication failed or missing (status code 401)
     * @see DailyMenuApi#removeDailyMenu
     */
    default ResponseEntity<Void> removeDailyMenu(Long recipeId) {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
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
