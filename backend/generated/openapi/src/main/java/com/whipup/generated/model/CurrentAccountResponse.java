package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.UserSummary;
import org.springframework.lang.Nullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * CurrentAccountResponse
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class CurrentAccountResponse {

  private UserSummary user;

  private Boolean hasOwnedIngredients;

  private Boolean onboardingCompleted;

  private Boolean termsConsentRequired;

  public CurrentAccountResponse() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public CurrentAccountResponse(UserSummary user, Boolean hasOwnedIngredients, Boolean onboardingCompleted, Boolean termsConsentRequired) {
    this.user = user;
    this.hasOwnedIngredients = hasOwnedIngredients;
    this.onboardingCompleted = onboardingCompleted;
    this.termsConsentRequired = termsConsentRequired;
  }

  public CurrentAccountResponse user(UserSummary user) {
    this.user = user;
    return this;
  }

  /**
   * Get user
   * @return user
   */
  @NotNull @Valid 
  @JsonProperty("user")
  public UserSummary getUser() {
    return user;
  }

  @JsonProperty("user")
  public void setUser(UserSummary user) {
    this.user = user;
  }

  public CurrentAccountResponse hasOwnedIngredients(Boolean hasOwnedIngredients) {
    this.hasOwnedIngredients = hasOwnedIngredients;
    return this;
  }

  /**
   * Get hasOwnedIngredients
   * @return hasOwnedIngredients
   */
  @NotNull 
  @JsonProperty("hasOwnedIngredients")
  public Boolean getHasOwnedIngredients() {
    return hasOwnedIngredients;
  }

  @JsonProperty("hasOwnedIngredients")
  public void setHasOwnedIngredients(Boolean hasOwnedIngredients) {
    this.hasOwnedIngredients = hasOwnedIngredients;
  }

  public CurrentAccountResponse onboardingCompleted(Boolean onboardingCompleted) {
    this.onboardingCompleted = onboardingCompleted;
    return this;
  }

  /**
   * Get onboardingCompleted
   * @return onboardingCompleted
   */
  @NotNull 
  @JsonProperty("onboardingCompleted")
  public Boolean getOnboardingCompleted() {
    return onboardingCompleted;
  }

  @JsonProperty("onboardingCompleted")
  public void setOnboardingCompleted(Boolean onboardingCompleted) {
    this.onboardingCompleted = onboardingCompleted;
  }

  public CurrentAccountResponse termsConsentRequired(Boolean termsConsentRequired) {
    this.termsConsentRequired = termsConsentRequired;
    return this;
  }

  /**
   * Get termsConsentRequired
   * @return termsConsentRequired
   */
  @NotNull 
  @JsonProperty("termsConsentRequired")
  public Boolean getTermsConsentRequired() {
    return termsConsentRequired;
  }

  @JsonProperty("termsConsentRequired")
  public void setTermsConsentRequired(Boolean termsConsentRequired) {
    this.termsConsentRequired = termsConsentRequired;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    CurrentAccountResponse currentAccountResponse = (CurrentAccountResponse) o;
    return Objects.equals(this.user, currentAccountResponse.user) &&
        Objects.equals(this.hasOwnedIngredients, currentAccountResponse.hasOwnedIngredients) &&
        Objects.equals(this.onboardingCompleted, currentAccountResponse.onboardingCompleted) &&
        Objects.equals(this.termsConsentRequired, currentAccountResponse.termsConsentRequired);
  }

  @Override
  public int hashCode() {
    return Objects.hash(user, hasOwnedIngredients, onboardingCompleted, termsConsentRequired);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class CurrentAccountResponse {\n");
    sb.append("    user: ").append(toIndentedString(user)).append("\n");
    sb.append("    hasOwnedIngredients: ").append(toIndentedString(hasOwnedIngredients)).append("\n");
    sb.append("    onboardingCompleted: ").append(toIndentedString(onboardingCompleted)).append("\n");
    sb.append("    termsConsentRequired: ").append(toIndentedString(termsConsentRequired)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(@Nullable Object o) {
    return o == null ? "null" : o.toString().replace("\n", "\n    ");
  }
}

