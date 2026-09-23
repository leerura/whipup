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
 * MissingIngredient
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class MissingIngredient {

  private Long ingredientId;

  private String name;

  public MissingIngredient() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public MissingIngredient(Long ingredientId, String name) {
    this.ingredientId = ingredientId;
    this.name = name;
  }

  public MissingIngredient ingredientId(Long ingredientId) {
    this.ingredientId = ingredientId;
    return this;
  }

  /**
   * Get ingredientId
   * @return ingredientId
   */
  @NotNull 
  @JsonProperty("ingredientId")
  public Long getIngredientId() {
    return ingredientId;
  }

  @JsonProperty("ingredientId")
  public void setIngredientId(Long ingredientId) {
    this.ingredientId = ingredientId;
  }

  public MissingIngredient name(String name) {
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
    MissingIngredient missingIngredient = (MissingIngredient) o;
    return Objects.equals(this.ingredientId, missingIngredient.ingredientId) &&
        Objects.equals(this.name, missingIngredient.name);
  }

  @Override
  public int hashCode() {
    return Objects.hash(ingredientId, name);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class MissingIngredient {\n");
    sb.append("    ingredientId: ").append(toIndentedString(ingredientId)).append("\n");
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

