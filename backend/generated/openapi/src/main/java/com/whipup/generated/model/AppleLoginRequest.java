package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import org.springframework.lang.Nullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * AppleLoginRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class AppleLoginRequest {

  private String identityToken;

  private String authorizationCode;

  private String nonce;

  public AppleLoginRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public AppleLoginRequest(String identityToken, String authorizationCode, String nonce) {
    this.identityToken = identityToken;
    this.authorizationCode = authorizationCode;
    this.nonce = nonce;
  }

  public AppleLoginRequest identityToken(String identityToken) {
    this.identityToken = identityToken;
    return this;
  }

  /**
   * Apple identity token (JWT) returned to the app.
   * @return identityToken
   */
  @NotNull 
  @JsonProperty("identityToken")
  public String getIdentityToken() {
    return identityToken;
  }

  @JsonProperty("identityToken")
  public void setIdentityToken(String identityToken) {
    this.identityToken = identityToken;
  }

  public AppleLoginRequest authorizationCode(String authorizationCode) {
    this.authorizationCode = authorizationCode;
    return this;
  }

  /**
   * Short-lived Apple authorization code the server exchanges with Apple.
   * @return authorizationCode
   */
  @NotNull 
  @JsonProperty("authorizationCode")
  public String getAuthorizationCode() {
    return authorizationCode;
  }

  @JsonProperty("authorizationCode")
  public void setAuthorizationCode(String authorizationCode) {
    this.authorizationCode = authorizationCode;
  }

  public AppleLoginRequest nonce(String nonce) {
    this.nonce = nonce;
    return this;
  }

  /**
   * Raw nonce the app generated; its SHA-256 hex digest was sent to Apple.
   * @return nonce
   */
  @NotNull 
  @JsonProperty("nonce")
  public String getNonce() {
    return nonce;
  }

  @JsonProperty("nonce")
  public void setNonce(String nonce) {
    this.nonce = nonce;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    AppleLoginRequest appleLoginRequest = (AppleLoginRequest) o;
    return Objects.equals(this.identityToken, appleLoginRequest.identityToken) &&
        Objects.equals(this.authorizationCode, appleLoginRequest.authorizationCode) &&
        Objects.equals(this.nonce, appleLoginRequest.nonce);
  }

  @Override
  public int hashCode() {
    return Objects.hash(identityToken, authorizationCode, nonce);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class AppleLoginRequest {\n");
    sb.append("    identityToken: ").append(toIndentedString(identityToken)).append("\n");
    sb.append("    authorizationCode: ").append(toIndentedString(authorizationCode)).append("\n");
    sb.append("    nonce: ").append(toIndentedString(nonce)).append("\n");
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

