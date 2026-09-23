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
 * IngredientOption
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-09-23T01:37:49.076375542Z[Etc/UTC]", comments = "Generator version: 7.19.0")
public class IngredientOption {

  private Long ingredientId;

  private String displayName;

  public IngredientOption() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public IngredientOption(Long ingredientId, String displayName) {
    this.ingredientId = ingredientId;
    this.displayName = displayName;
  }

  public IngredientOption ingredientId(Long ingredientId) {
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

  public IngredientOption displayName(String displayName) {
    this.displayName = displayName;
    return this;
  }

  /**
   * Get displayName
   * @return displayName
   */
  @NotNull 
  @Schema(name = "displayName", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("displayName")
  public String getDisplayName() {
    return displayName;
  }

  public void setDisplayName(String displayName) {
    this.displayName = displayName;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    IngredientOption ingredientOption = (IngredientOption) o;
    return Objects.equals(this.ingredientId, ingredientOption.ingredientId) &&
        Objects.equals(this.displayName, ingredientOption.displayName);
  }

  @Override
  public int hashCode() {
    return Objects.hash(ingredientId, displayName);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class IngredientOption {\n");
    sb.append("    ingredientId: ").append(toIndentedString(ingredientId)).append("\n");
    sb.append("    displayName: ").append(toIndentedString(displayName)).append("\n");
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

