package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.UserSummary;
import org.springframework.lang.Nullable;
import org.openapitools.jackson.nullable.JsonNullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import io.swagger.v3.oas.annotations.media.Schema;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * LoginResponse
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.19.0")
public class LoginResponse {

  private String accessToken;

  private UserSummary user;

  private Boolean hasOwnedIngredients;

  public LoginResponse() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public LoginResponse(String accessToken, UserSummary user, Boolean hasOwnedIngredients) {
    this.accessToken = accessToken;
    this.user = user;
    this.hasOwnedIngredients = hasOwnedIngredients;
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
  @Schema(name = "accessToken", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("accessToken")
  public String getAccessToken() {
    return accessToken;
  }

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
  @Schema(name = "user", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("user")
  public UserSummary getUser() {
    return user;
  }

  public void setUser(UserSummary user) {
    this.user = user;
  }

  public LoginResponse hasOwnedIngredients(Boolean hasOwnedIngredients) {
    this.hasOwnedIngredients = hasOwnedIngredients;
    return this;
  }

  /**
   * Get hasOwnedIngredients
   * @return hasOwnedIngredients
   */
  @NotNull 
  @Schema(name = "hasOwnedIngredients", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("hasOwnedIngredients")
  public Boolean getHasOwnedIngredients() {
    return hasOwnedIngredients;
  }

  public void setHasOwnedIngredients(Boolean hasOwnedIngredients) {
    this.hasOwnedIngredients = hasOwnedIngredients;
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
        Objects.equals(this.hasOwnedIngredients, loginResponse.hasOwnedIngredients);
  }

  @Override
  public int hashCode() {
    return Objects.hash(accessToken, user, hasOwnedIngredients);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class LoginResponse {\n");
    sb.append("    accessToken: ").append(toIndentedString(accessToken)).append("\n");
    sb.append("    user: ").append(toIndentedString(user)).append("\n");
    sb.append("    hasOwnedIngredients: ").append(toIndentedString(hasOwnedIngredients)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(@Nullable Object o) {
    if (o == null) {
      return "null";
    }
    return o.toString().replace("\n", "\n    ");
  }
}

