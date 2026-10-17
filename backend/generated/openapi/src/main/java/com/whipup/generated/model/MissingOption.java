package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.MissingSubstitute;
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
 * MissingOption
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class MissingOption {

  private String requiredName;

  private List<@Valid MissingSubstitute> substitutes = new ArrayList<>();

  public MissingOption() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public MissingOption(String requiredName, List<@Valid MissingSubstitute> substitutes) {
    this.requiredName = requiredName;
    this.substitutes = substitutes;
  }

  public MissingOption requiredName(String requiredName) {
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

  public MissingOption substitutes(List<@Valid MissingSubstitute> substitutes) {
    this.substitutes = substitutes;
    return this;
  }

  public MissingOption addSubstitutesItem(MissingSubstitute substitutesItem) {
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
  public List<@Valid MissingSubstitute> getSubstitutes() {
    return substitutes;
  }

  @JsonProperty("substitutes")
  public void setSubstitutes(List<@Valid MissingSubstitute> substitutes) {
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
    MissingOption missingOption = (MissingOption) o;
    return Objects.equals(this.requiredName, missingOption.requiredName) &&
        Objects.equals(this.substitutes, missingOption.substitutes);
  }

  @Override
  public int hashCode() {
    return Objects.hash(requiredName, substitutes);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class MissingOption {\n");
    sb.append("    requiredName: ").append(toIndentedString(requiredName)).append("\n");
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

