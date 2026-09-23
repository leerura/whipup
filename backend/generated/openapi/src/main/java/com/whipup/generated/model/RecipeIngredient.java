package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.Arrays;
import org.openapitools.jackson.nullable.JsonNullable;
import org.springframework.lang.Nullable;
import java.util.NoSuchElementException;
import org.openapitools.jackson.nullable.JsonNullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import io.swagger.v3.oas.annotations.media.Schema;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * RecipeIngredient
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class RecipeIngredient {

  private Long recipeIngredientId;

  private Long ingredientId;

  private String displayName;

  private JsonNullable<String> amount = JsonNullable.<String>undefined();

  private JsonNullable<String> unit = JsonNullable.<String>undefined();

  private Integer displayOrder;

  private Boolean owned;

  public RecipeIngredient() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public RecipeIngredient(Long recipeIngredientId, Long ingredientId, String displayName, Integer displayOrder, Boolean owned) {
    this.recipeIngredientId = recipeIngredientId;
    this.ingredientId = ingredientId;
    this.displayName = displayName;
    this.displayOrder = displayOrder;
    this.owned = owned;
  }

  public RecipeIngredient recipeIngredientId(Long recipeIngredientId) {
    this.recipeIngredientId = recipeIngredientId;
    return this;
  }

  /**
   * Get recipeIngredientId
   * @return recipeIngredientId
   */
  @NotNull 
  @Schema(name = "recipeIngredientId", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("recipeIngredientId")
  public Long getRecipeIngredientId() {
    return recipeIngredientId;
  }

  @JsonProperty("recipeIngredientId")
  public void setRecipeIngredientId(Long recipeIngredientId) {
    this.recipeIngredientId = recipeIngredientId;
  }

  public RecipeIngredient ingredientId(Long ingredientId) {
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

  @JsonProperty("ingredientId")
  public void setIngredientId(Long ingredientId) {
    this.ingredientId = ingredientId;
  }

  public RecipeIngredient displayName(String displayName) {
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

  @JsonProperty("displayName")
  public void setDisplayName(String displayName) {
    this.displayName = displayName;
  }

  public RecipeIngredient amount(String amount) {
    this.amount = JsonNullable.of(amount);
    return this;
  }

  /**
   * Get amount
   * @return amount
   */
  
  @Schema(name = "amount", requiredMode = Schema.RequiredMode.NOT_REQUIRED, nullable = true)
  @JsonProperty("amount")
  public JsonNullable<String> getAmount() {
    return amount;
  }

  public void setAmount(JsonNullable<String> amount) {
    this.amount = amount;
  }

  public RecipeIngredient unit(String unit) {
    this.unit = JsonNullable.of(unit);
    return this;
  }

  /**
   * Get unit
   * @return unit
   */
  
  @Schema(name = "unit", requiredMode = Schema.RequiredMode.NOT_REQUIRED, nullable = true)
  @JsonProperty("unit")
  public JsonNullable<String> getUnit() {
    return unit;
  }

  public void setUnit(JsonNullable<String> unit) {
    this.unit = unit;
  }

  public RecipeIngredient displayOrder(Integer displayOrder) {
    this.displayOrder = displayOrder;
    return this;
  }

  /**
   * Get displayOrder
   * minimum: 1
   * @return displayOrder
   */
  @NotNull @Min(value = 1) 
  @Schema(name = "displayOrder", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("displayOrder")
  public Integer getDisplayOrder() {
    return displayOrder;
  }

  @JsonProperty("displayOrder")
  public void setDisplayOrder(Integer displayOrder) {
    this.displayOrder = displayOrder;
  }

  public RecipeIngredient owned(Boolean owned) {
    this.owned = owned;
    return this;
  }

  /**
   * Get owned
   * @return owned
   */
  @NotNull 
  @Schema(name = "owned", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("owned")
  public Boolean getOwned() {
    return owned;
  }

  @JsonProperty("owned")
  public void setOwned(Boolean owned) {
    this.owned = owned;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    RecipeIngredient recipeIngredient = (RecipeIngredient) o;
    return Objects.equals(this.recipeIngredientId, recipeIngredient.recipeIngredientId) &&
        Objects.equals(this.ingredientId, recipeIngredient.ingredientId) &&
        Objects.equals(this.displayName, recipeIngredient.displayName) &&
        equalsNullable(this.amount, recipeIngredient.amount) &&
        equalsNullable(this.unit, recipeIngredient.unit) &&
        Objects.equals(this.displayOrder, recipeIngredient.displayOrder) &&
        Objects.equals(this.owned, recipeIngredient.owned);
  }

  private static <T> boolean equalsNullable(JsonNullable<T> a, JsonNullable<T> b) {
    return a == b || (a != null && b != null && a.isPresent() && b.isPresent() && Objects.deepEquals(a.get(), b.get()));
  }

  @Override
  public int hashCode() {
    return Objects.hash(recipeIngredientId, ingredientId, displayName, hashCodeNullable(amount), hashCodeNullable(unit), displayOrder, owned);
  }

  private static <T> int hashCodeNullable(JsonNullable<T> a) {
    if (a == null) {
      return 1;
    }
    return a.isPresent() ? Arrays.deepHashCode(new Object[]{a.get()}) : 31;
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class RecipeIngredient {\n");
    sb.append("    recipeIngredientId: ").append(toIndentedString(recipeIngredientId)).append("\n");
    sb.append("    ingredientId: ").append(toIndentedString(ingredientId)).append("\n");
    sb.append("    displayName: ").append(toIndentedString(displayName)).append("\n");
    sb.append("    amount: ").append(toIndentedString(amount)).append("\n");
    sb.append("    unit: ").append(toIndentedString(unit)).append("\n");
    sb.append("    displayOrder: ").append(toIndentedString(displayOrder)).append("\n");
    sb.append("    owned: ").append(toIndentedString(owned)).append("\n");
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

