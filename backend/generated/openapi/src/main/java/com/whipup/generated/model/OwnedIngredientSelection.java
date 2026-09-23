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
 * OwnedIngredientSelection
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-09-23T01:37:49.076375542Z[Etc/UTC]", comments = "Generator version: 7.19.0")
public class OwnedIngredientSelection {

  private Long ingredientId;

  public OwnedIngredientSelection() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public OwnedIngredientSelection(Long ingredientId) {
    this.ingredientId = ingredientId;
  }

  public OwnedIngredientSelection ingredientId(Long ingredientId) {
    this.ingredientId = ingredientId;
    return this;
  }

  /**
   * Get ingredientId
   * @return ingredientId
   */
  @NotNull 
  @Schema(name = "ingredientId", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("ingredientId")
  public Long getIngredientId() {
    return ingredientId;
  }

  public void setIngredientId(Long ingredientId) {
    this.ingredientId = ingredientId;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    OwnedIngredientSelection ownedIngredientSelection = (OwnedIngredientSelection) o;
    return Objects.equals(this.ingredientId, ownedIngredientSelection.ingredientId);
  }

  @Override
  public int hashCode() {
    return Objects.hash(ingredientId);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class OwnedIngredientSelection {\n");
    sb.append("    ingredientId: ").append(toIndentedString(ingredientId)).append("\n");
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

