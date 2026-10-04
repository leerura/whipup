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
 * OwnedIngredient
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class OwnedIngredient {

  private Long userIngredientId;

  private Long variantId;

  private String name;

  public OwnedIngredient() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public OwnedIngredient(Long userIngredientId, Long variantId, String name) {
    this.userIngredientId = userIngredientId;
    this.variantId = variantId;
    this.name = name;
  }

  public OwnedIngredient userIngredientId(Long userIngredientId) {
    this.userIngredientId = userIngredientId;
    return this;
  }

  /**
   * Get userIngredientId
   * @return userIngredientId
   */
  @NotNull 
  @JsonProperty("userIngredientId")
  public Long getUserIngredientId() {
    return userIngredientId;
  }

  @JsonProperty("userIngredientId")
  public void setUserIngredientId(Long userIngredientId) {
    this.userIngredientId = userIngredientId;
  }

  public OwnedIngredient variantId(Long variantId) {
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

  public OwnedIngredient name(String name) {
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
    OwnedIngredient ownedIngredient = (OwnedIngredient) o;
    return Objects.equals(this.userIngredientId, ownedIngredient.userIngredientId) &&
        Objects.equals(this.variantId, ownedIngredient.variantId) &&
        Objects.equals(this.name, ownedIngredient.name);
  }

  @Override
  public int hashCode() {
    return Objects.hash(userIngredientId, variantId, name);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class OwnedIngredient {\n");
    sb.append("    userIngredientId: ").append(toIndentedString(userIngredientId)).append("\n");
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

