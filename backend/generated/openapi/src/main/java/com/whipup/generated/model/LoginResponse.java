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
 * LoginResponse
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class LoginResponse {

  private String accessToken;

  private UserSummary user;

  private Boolean hasOwnedIngredients;

  private Boolean onboardingCompleted;

  public LoginResponse() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public LoginResponse(String accessToken, UserSummary user, Boolean hasOwnedIngredients, Boolean onboardingCompleted) {
    this.accessToken = accessToken;
    this.user = user;
    this.hasOwnedIngredients = hasOwnedIngredients;
    this.onboardingCompleted = onboardingCompleted;
  }

  public LoginResponse accessToken(String accessToken) {
    this.accessToken = accessToken;
    return this;
  }

  /**
   * Get accessToken
   * @return accessToken
   */
  @NotNull
  @JsonProperty("accessToken")
  public String getAccessToken() {
    return accessToken;
  }

  @JsonProperty("accessToken")
  public void setAccessToken(String accessToken) {
    this.accessToken = accessToken;
  }

  public LoginResponse user(UserSummary user) {
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

  public LoginResponse hasOwnedIngredients(Boolean hasOwnedIngredients) {
    this.hasOwnedIngredients = hasOwnedIngredients;
    return this;
  }

  /**
   * Whether the account currently has any owned ingredient rows.
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

  public LoginResponse onboardingCompleted(Boolean onboardingCompleted) {
    this.onboardingCompleted = onboardingCompleted;
    return this;
  }

  /**
   * Whether the account has completed initial ingredient registration. Remains true if all owned ingredients are later deleted.
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

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    LoginResponse loginResponse = (LoginResponse) o;
    return Objects.equals(this.accessToken, loginResponse.accessToken) &&
        Objects.equals(this.user, loginResponse.user) &&
        Objects.equals(this.hasOwnedIngredients, loginResponse.hasOwnedIngredients) &&
        Objects.equals(this.onboardingCompleted, loginResponse.onboardingCompleted);
  }

  @Override
  public int hashCode() {
    return Objects.hash(accessToken, user, hasOwnedIngredients, onboardingCompleted);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class LoginResponse {\n");
    sb.append("    accessToken: ").append(toIndentedString(accessToken)).append("\n");
    sb.append("    user: ").append(toIndentedString(user)).append("\n");
    sb.append("    hasOwnedIngredients: ").append(toIndentedString(hasOwnedIngredients)).append("\n");
    sb.append("    onboardingCompleted: ").append(toIndentedString(onboardingCompleted)).append("\n");
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

