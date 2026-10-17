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
 * IngredientVariantOption
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class IngredientVariantOption {

  private Long variantId;

  private String name;

  public IngredientVariantOption() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public IngredientVariantOption(Long variantId, String name) {
    this.variantId = variantId;
    this.name = name;
  }

  public IngredientVariantOption variantId(Long variantId) {
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

  public IngredientVariantOption name(String name) {
    this.name = name;
    return this;
  }

  /**
   * Get name
   * @return name
   */
  @NotNull 
  @JsonProperty("name")
  public String getName() {
    return name;
  }

  @JsonProperty("name")
  public void setName(String name) {
    this.name = name;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    IngredientVariantOption ingredientVariantOption = (IngredientVariantOption) o;
    return Objects.equals(this.variantId, ingredientVariantOption.variantId) &&
        Objects.equals(this.name, ingredientVariantOption.name);
  }

  @Override
  public int hashCode() {
    return Objects.hash(variantId, name);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class IngredientVariantOption {\n");
    sb.append("    variantId: ").append(toIndentedString(variantId)).append("\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
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

