package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import org.springframework.lang.Nullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * IngredientMatch
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class IngredientMatch {

  /**
   * Gets or Sets type
   */
  public enum TypeEnum {
    DIRECT("DIRECT"),
    
    PREPARATION("PREPARATION"),
    
    SUBSTITUTE("SUBSTITUTE");

    private final String value;

    TypeEnum(String value) {
      this.value = value;
    }

    @JsonValue
    public String getValue() {
      return value;
    }

    @Override
    public String toString() {
      return String.valueOf(value);
    }

    @JsonCreator
    public static TypeEnum fromValue(String value) {
      for (TypeEnum b : TypeEnum.values()) {
        if (b.value.equals(value)) {
          return b;
        }
      }
      throw new IllegalArgumentException("Unexpected value '" + value + "'");
    }
  }

  private TypeEnum type;

  private String requiredName;

  private String ownedName;

  public IngredientMatch() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public IngredientMatch(TypeEnum type, String requiredName, String ownedName) {
    this.type = type;
    this.requiredName = requiredName;
    this.ownedName = ownedName;
  }

  public IngredientMatch type(TypeEnum type) {
    this.type = type;
    return this;
  }

  /**
   * Get type
   * @return type
   */
  @NotNull 
  @JsonProperty("type")
  public TypeEnum getType() {
    return type;
  }

  @JsonProperty("type")
  public void setType(TypeEnum type) {
    this.type = type;
  }

  public IngredientMatch requiredName(String requiredName) {
    this.requiredName = requiredName;
    return this;
  }

  /**
   * Get requiredName
   * @return requiredName
   */
  @NotNull 
  @JsonProperty("requiredName")
  public String getRequiredName() {
    return requiredName;
  }

  @JsonProperty("requiredName")
  public void setRequiredName(String requiredName) {
    this.requiredName = requiredName;
  }

  public IngredientMatch ownedName(String ownedName) {
    this.ownedName = ownedName;
    return this;
  }

  /**
   * Get ownedName
   * @return ownedName
   */
  @NotNull 
  @JsonProperty("ownedName")
  public String getOwnedName() {
    return ownedName;
  }

  @JsonProperty("ownedName")
  public void setOwnedName(String ownedName) {
    this.ownedName = ownedName;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    IngredientMatch ingredientMatch = (IngredientMatch) o;
    return Objects.equals(this.type, ingredientMatch.type) &&
        Objects.equals(this.requiredName, ingredientMatch.requiredName) &&
        Objects.equals(this.ownedName, ingredientMatch.ownedName);
  }

  @Override
  public int hashCode() {
    return Objects.hash(type, requiredName, ownedName);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class IngredientMatch {\n");
    sb.append("    type: ").append(toIndentedString(type)).append("\n");
    sb.append("    requiredName: ").append(toIndentedString(requiredName)).append("\n");
    sb.append("    ownedName: ").append(toIndentedString(ownedName)).append("\n");
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

