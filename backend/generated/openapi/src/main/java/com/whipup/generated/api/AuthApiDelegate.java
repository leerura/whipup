package com.whipup.generated.api;

import com.whipup.generated.model.CurrentAccountResponse;
import com.whipup.generated.model.ErrorResponse;
import com.whipup.generated.model.LoginResponse;
import com.whipup.generated.model.TermsConsentRequest;
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
 * A delegate to be called by the {@link AuthApiController}}.
 * Implement this interface with a {@link org.springframework.stereotype.Service} annotated class.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public interface AuthApiDelegate {

    default Optional<NativeWebRequest> getRequest() {
        return Optional.empty();
    }

    /**
     * POST /api/v1/me/terms-consent
     *
     * @param termsConsentRequest  (required)
     * @return Terms accepted (status code 204)
     *         or Invalid request (status code 400)
     *         or Authentication failed or missing (status code 401)
     * @see AuthApi#acceptTermsConsent
     */
    default ResponseEntity<Void> acceptTermsConsent(TermsConsentRequest termsConsentRequest) {
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
     * DELETE /api/v1/me : Permanently delete the authenticated account
     * Permanently deletes the current user, linked provider accounts, owned ingredients, and onboarding state in one transaction. No backup is retained. Shared ingredient/catalog and recipe data are not deleted. Logout does not exist; after deletion the app starts a new guest account.
     *
     * @return Account deleted (status code 204)
     *         or Authentication failed or missing (status code 401)
     * @see AuthApi#deleteCurrentAccount
     */
    default ResponseEntity<Void> deleteCurrentAccount() {
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

    /**
     * GET /api/v1/me : Read the authenticated account state
     * Returns the same account state fields as LoginResponse without issuing a token. Callable while terms consent is still pending.
     *
     * @return Current account state (status code 200)
     *         or Authentication failed or missing (status code 401)
     * @see AuthApi#getCurrentAccount
     */
    default ResponseEntity<CurrentAccountResponse> getCurrentAccount() {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"user\" : { \"userId\" : 0 }, \"hasOwnedIngredients\" : true, \"onboardingCompleted\" : true, \"termsConsentRequired\" : true }";
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
     * POST /api/v1/auth/guest : Create a guest account without personal information
     * Creates a new account with no personal information and returns the same LoginResponse shape as before. The account always starts with terms consent required and onboarding incomplete.
     *
     * @return Guest account created (status code 200)
     * @see AuthApi#startGuestSession
     */
    default ResponseEntity<LoginResponse> startGuestSession() {
        getRequest().ifPresent(request -> {
            for (MediaType mediaType: MediaType.parseMediaTypes(request.getHeader("Accept"))) {
                if (mediaType.isCompatibleWith(MediaType.valueOf("application/json"))) {
                    String exampleString = "{ \"accessToken\" : \"accessToken\", \"user\" : { \"userId\" : 0 }, \"hasOwnedIngredients\" : true, \"onboardingCompleted\" : true, \"termsConsentRequired\" : true }";
                    ApiUtil.setExampleResponse(request, "application/json", exampleString);
                    break;
                }
            }
        });
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);

    }

}
