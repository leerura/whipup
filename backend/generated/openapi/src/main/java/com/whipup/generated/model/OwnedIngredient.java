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

  private Long ingredientId;

  private String displayName;

  public OwnedIngredient() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public OwnedIngredient(Long userIngredientId, Long ingredientId, String displayName) {
    this.userIngredientId = userIngredientId;
    this.ingredientId = ingredientId;
    this.displayName = displayName;
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

  public OwnedIngredient ingredientId(Long ingredientId) {
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

  public OwnedIngredient displayName(String displayName) {
    this.displayName = displayName;
    return this;
  }

  /**
   * Get displayName
   * @return displayName
   */
  @NotNull 
  @JsonProperty("displayName")
  public String getDisplayName() {
    return displayName;
  }

  @JsonProperty("displayName")
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
    OwnedIngredient ownedIngredient = (OwnedIngredient) o;
    return Objects.equals(this.userIngredientId, ownedIngredient.userIngredientId) &&
        Objects.equals(this.ingredientId, ownedIngredient.ingredientId) &&
        Objects.equals(this.displayName, ownedIngredient.displayName);
  }

  @Override
  public int hashCode() {
    return Objects.hash(userIngredientId, ingredientId, displayName);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class OwnedIngredient {\n");
    sb.append("    userIngredientId: ").append(toIndentedString(userIngredientId)).append("\n");
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
    return o == null ? "null" : o.toString().replace("\n", "\n    ");
  }
}

