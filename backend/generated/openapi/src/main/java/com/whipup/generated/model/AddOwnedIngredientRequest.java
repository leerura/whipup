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
 * AddOwnedIngredientRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class AddOwnedIngredientRequest {

  private Long variantId;

  public AddOwnedIngredientRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public AddOwnedIngredientRequest(Long variantId) {
    this.variantId = variantId;
  }

  public AddOwnedIngredientRequest variantId(Long variantId) {
    this.variantId = variantId;
    return this;
  }

  /**
   * Get variantId
   * @return variantId
   */
  @NotNull 
  @JsonProperty("variantId")
  public Long getVariantId() {
    return variantId;
  }

  @JsonProperty("variantId")
  public void setVariantId(Long variantId) {
    this.variantId = variantId;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    AddOwnedIngredientRequest addOwnedIngredientRequest = (AddOwnedIngredientRequest) o;
    return Objects.equals(this.variantId, addOwnedIngredientRequest.variantId);
  }

  @Override
  public int hashCode() {
    return Objects.hash(variantId);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class AddOwnedIngredientRequest {\n");
    sb.append("    variantId: ").append(toIndentedString(variantId)).append("\n");
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

