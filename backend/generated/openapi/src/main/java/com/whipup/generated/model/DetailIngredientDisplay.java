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
 * DetailIngredientDisplay
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class DetailIngredientDisplay {

  private String displayName;

  private String rawText;

  private @Nullable String amount = null;

  private @Nullable String unit = null;

  public DetailIngredientDisplay() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public DetailIngredientDisplay(String displayName, String rawText) {
    this.displayName = displayName;
    this.rawText = rawText;
  }

  public DetailIngredientDisplay displayName(String displayName) {
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

  public DetailIngredientDisplay rawText(String rawText) {
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

  public DetailIngredientDisplay amount(@Nullable String amount) {
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

  public DetailIngredientDisplay unit(@Nullable String unit) {
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

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    DetailIngredientDisplay detailIngredientDisplay = (DetailIngredientDisplay) o;
    return Objects.equals(this.displayName, detailIngredientDisplay.displayName) &&
        Objects.equals(this.rawText, detailIngredientDisplay.rawText) &&
        Objects.equals(this.amount, detailIngredientDisplay.amount) &&
        Objects.equals(this.unit, detailIngredientDisplay.unit);
  }

  @Override
  public int hashCode() {
    return Objects.hash(displayName, rawText, amount, unit);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class DetailIngredientDisplay {\n");
    sb.append("    displayName: ").append(toIndentedString(displayName)).append("\n");
    sb.append("    rawText: ").append(toIndentedString(rawText)).append("\n");
    sb.append("    amount: ").append(toIndentedString(amount)).append("\n");
    sb.append("    unit: ").append(toIndentedString(unit)).append("\n");
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

