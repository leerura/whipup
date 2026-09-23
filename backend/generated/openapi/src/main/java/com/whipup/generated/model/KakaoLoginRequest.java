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
 * KakaoLoginRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class KakaoLoginRequest {

  private String kakaoAccessToken;

  public KakaoLoginRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public KakaoLoginRequest(String kakaoAccessToken) {
    this.kakaoAccessToken = kakaoAccessToken;
  }

  public KakaoLoginRequest kakaoAccessToken(String kakaoAccessToken) {
    this.kakaoAccessToken = kakaoAccessToken;
    return this;
  }

  /**
   * Get kakaoAccessToken
   * @return kakaoAccessToken
   */
  @NotNull 
  @JsonProperty("kakaoAccessToken")
  public String getKakaoAccessToken() {
    return kakaoAccessToken;
  }

  @JsonProperty("kakaoAccessToken")
  public void setKakaoAccessToken(String kakaoAccessToken) {
    this.kakaoAccessToken = kakaoAccessToken;
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
    return Objects.equals(this.kakaoAccessToken, kakaoLoginRequest.kakaoAccessToken);
  }

  @Override
  public int hashCode() {
    return Objects.hash(kakaoAccessToken);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class KakaoLoginRequest {\n");
    sb.append("    kakaoAccessToken: ").append(toIndentedString(kakaoAccessToken)).append("\n");
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

