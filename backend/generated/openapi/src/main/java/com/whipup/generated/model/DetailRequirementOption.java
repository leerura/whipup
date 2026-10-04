package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.DetailIngredientDisplay;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.lang.Nullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * DetailRequirementOption
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class DetailRequirementOption {

  private String displayName;

  private String rawText;

  private @Nullable String amount = null;

  private @Nullable String unit = null;

  private List<@Valid DetailIngredientDisplay> substitutes = new ArrayList<>();

  public DetailRequirementOption() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public DetailRequirementOption(String displayName, String rawText, List<@Valid DetailIngredientDisplay> substitutes) {
    this.displayName = displayName;
    this.rawText = rawText;
    this.substitutes = substitutes;
  }

  public DetailRequirementOption displayName(String displayName) {
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

  public DetailRequirementOption rawText(String rawText) {
    this.rawText = rawText;
    return this;
  }

  /**
   * Get rawText
   * @return rawText
   */
  @NotNull 
  @JsonProperty("rawText")
  public String getRawText() {
    return rawText;
  }

  @JsonProperty("rawText")
  public void setRawText(String rawText) {
    this.rawText = rawText;
  }

  public DetailRequirementOption amount(@Nullable String amount) {
    this.amount = amount;
    return this;
  }

  /**
   * Get amount
   * @return amount
   */
  
  @JsonProperty("amount")
  public @Nullable String getAmount() {
    return amount;
  }

  @JsonProperty("amount")
  public void setAmount(@Nullable String amount) {
    this.amount = amount;
  }

  public DetailRequirementOption unit(@Nullable String unit) {
    this.unit = unit;
    return this;
  }

  /**
   * Get unit
   * @return unit
   */
  
  @JsonProperty("unit")
  public @Nullable String getUnit() {
    return unit;
  }

  @JsonProperty("unit")
  public void setUnit(@Nullable String unit) {
    this.unit = unit;
  }

  public DetailRequirementOption substitutes(List<@Valid DetailIngredientDisplay> substitutes) {
    this.substitutes = substitutes;
    return this;
  }

  public DetailRequirementOption addSubstitutesItem(DetailIngredientDisplay substitutesItem) {
    if (this.substitutes == null) {
      this.substitutes = new ArrayList<>();
    }
    this.substitutes.add(substitutesItem);
    return this;
  }

  /**
   * Get substitutes
   * @return substitutes
   */
  @NotNull @Valid 
  @JsonProperty("substitutes")
  public List<@Valid DetailIngredientDisplay> getSubstitutes() {
    return substitutes;
  }

  @JsonProperty("substitutes")
  public void setSubstitutes(List<@Valid DetailIngredientDisplay> substitutes) {
    this.substitutes = substitutes;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    DetailRequirementOption detailRequirementOption = (DetailRequirementOption) o;
    return Objects.equals(this.displayName, detailRequirementOption.displayName) &&
        Objects.equals(this.rawText, detailRequirementOption.rawText) &&
        Objects.equals(this.amount, detailRequirementOption.amount) &&
        Objects.equals(this.unit, detailRequirementOption.unit) &&
        Objects.equals(this.substitutes, detailRequirementOption.substitutes);
  }

  @Override
  public int hashCode() {
    return Objects.hash(displayName, rawText, amount, unit, substitutes);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class DetailRequirementOption {\n");
    sb.append("    displayName: ").append(toIndentedString(displayName)).append("\n");
    sb.append("    rawText: ").append(toIndentedString(rawText)).append("\n");
    sb.append("    amount: ").append(toIndentedString(amount)).append("\n");
    sb.append("    unit: ").append(toIndentedString(unit)).append("\n");
    sb.append("    substitutes: ").append(toIndentedString(substitutes)).append("\n");
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

