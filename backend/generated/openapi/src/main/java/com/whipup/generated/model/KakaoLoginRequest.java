package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import org.springframework.lang.Nullable;
import org.openapitools.jackson.nullable.JsonNullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import io.swagger.v3.oas.annotations.media.Schema;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * KakaoLoginRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class KakaoLoginRequest {

  private String authorizationCode;

  public KakaoLoginRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public KakaoLoginRequest(String authorizationCode) {
    this.authorizationCode = authorizationCode;
  }

  public KakaoLoginRequest authorizationCode(String authorizationCode) {
    this.authorizationCode = authorizationCode;
    return this;
  }

  /**
   * Get authorizationCode
   * @return authorizationCode
   */
  @NotNull 
  @Schema(name = "authorizationCode", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("authorizationCode")
  public String getAuthorizationCode() {
    return authorizationCode;
  }

  @JsonProperty("authorizationCode")
  public void setAuthorizationCode(String authorizationCode) {
    this.authorizationCode = authorizationCode;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    KakaoLoginRequest kakaoLoginRequest = (KakaoLoginRequest) o;
    return Objects.equals(this.authorizationCode, kakaoLoginRequest.authorizationCode);
  }

  @Override
  public int hashCode() {
    return Objects.hash(authorizationCode);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class KakaoLoginRequest {\n");
    sb.append("    authorizationCode: ").append(toIndentedString(authorizationCode)).append("\n");
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

