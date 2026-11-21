package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.Set;
import org.springframework.lang.Nullable;
import tools.jackson.databind.annotation.JsonDeserialize;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * OnboardingRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class OnboardingRequest {

  private Set<Long> variantIds = new LinkedHashSet<>();

  public OnboardingRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public OnboardingRequest(Set<Long> variantIds) {
    this.variantIds = variantIds;
  }

  public OnboardingRequest variantIds(Set<Long> variantIds) {
    this.variantIds = variantIds;
    return this;
  }

  public OnboardingRequest addVariantIdsItem(Long variantIdsItem) {
    if (this.variantIds == null) {
      this.variantIds = new LinkedHashSet<>();
    }
    this.variantIds.add(variantIdsItem);
    return this;
  }

  /**
   * Get variantIds
   * @return variantIds
   */
  @NotNull 
  @JsonProperty("variantIds")
  public Set<Long> getVariantIds() {
    return variantIds;
  }

  @JsonDeserialize(as = LinkedHashSet.class)
  @JsonProperty("variantIds")
  public void setVariantIds(Set<Long> variantIds) {
    this.variantIds = variantIds;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    OnboardingRequest onboardingRequest = (OnboardingRequest) o;
    return Objects.equals(this.variantIds, onboardingRequest.variantIds);
  }

  @Override
  public int hashCode() {
    return Objects.hash(variantIds);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class OnboardingRequest {\n");
    sb.append("    variantIds: ").append(toIndentedString(variantIds)).append("\n");
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

