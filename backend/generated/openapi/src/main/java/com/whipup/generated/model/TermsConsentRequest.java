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
 * TermsConsentRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class TermsConsentRequest {

  private String termsVersion;

  private String privacyVersion;

  private Boolean age14OrOver;

  public TermsConsentRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public TermsConsentRequest(String termsVersion, String privacyVersion, Boolean age14OrOver) {
    this.termsVersion = termsVersion;
    this.privacyVersion = privacyVersion;
    this.age14OrOver = age14OrOver;
  }

  public TermsConsentRequest termsVersion(String termsVersion) {
    this.termsVersion = termsVersion;
    return this;
  }

  /**
   * Get termsVersion
   * @return termsVersion
   */
  @NotNull 
  @JsonProperty("termsVersion")
  public String getTermsVersion() {
    return termsVersion;
  }

  @JsonProperty("termsVersion")
  public void setTermsVersion(String termsVersion) {
    this.termsVersion = termsVersion;
  }

  public TermsConsentRequest privacyVersion(String privacyVersion) {
    this.privacyVersion = privacyVersion;
    return this;
  }

  /**
   * Get privacyVersion
   * @return privacyVersion
   */
  @NotNull 
  @JsonProperty("privacyVersion")
  public String getPrivacyVersion() {
    return privacyVersion;
  }

  @JsonProperty("privacyVersion")
  public void setPrivacyVersion(String privacyVersion) {
    this.privacyVersion = privacyVersion;
  }

  public TermsConsentRequest age14OrOver(Boolean age14OrOver) {
    this.age14OrOver = age14OrOver;
    return this;
  }

  /**
   * Get age14OrOver
   * @return age14OrOver
   */
  @NotNull 
  @JsonProperty("age14OrOver")
  public Boolean getAge14OrOver() {
    return age14OrOver;
  }

  @JsonProperty("age14OrOver")
  public void setAge14OrOver(Boolean age14OrOver) {
    this.age14OrOver = age14OrOver;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    TermsConsentRequest termsConsentRequest = (TermsConsentRequest) o;
    return Objects.equals(this.termsVersion, termsConsentRequest.termsVersion) &&
        Objects.equals(this.privacyVersion, termsConsentRequest.privacyVersion) &&
        Objects.equals(this.age14OrOver, termsConsentRequest.age14OrOver);
  }

  @Override
  public int hashCode() {
    return Objects.hash(termsVersion, privacyVersion, age14OrOver);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class TermsConsentRequest {\n");
    sb.append("    termsVersion: ").append(toIndentedString(termsVersion)).append("\n");
    sb.append("    privacyVersion: ").append(toIndentedString(privacyVersion)).append("\n");
    sb.append("    age14OrOver: ").append(toIndentedString(age14OrOver)).append("\n");
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

