package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import com.whipup.generated.model.MissingOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.lang.Nullable;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * MissingRequirementResult
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class MissingRequirementResult implements RequirementResult {

  /**
   * Gets or Sets status
   */
  public enum StatusEnum {
    MISSING("MISSING");

    private final String value;

    StatusEnum(String value) {
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
    public static StatusEnum fromValue(String value) {
      for (StatusEnum b : StatusEnum.values()) {
        if (b.value.equals(value)) {
          return b;
        }
      }
      throw new IllegalArgumentException("Unexpected value '" + value + "'");
    }
  }

  private StatusEnum status;

  private List<@Valid MissingOption> missingOptions = new ArrayList<>();

  public MissingRequirementResult() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public MissingRequirementResult(StatusEnum status, List<@Valid MissingOption> missingOptions) {
    this.status = status;
    this.missingOptions = missingOptions;
  }

  public MissingRequirementResult status(StatusEnum status) {
    this.status = status;
    return this;
  }

  /**
   * Get status
   * @return status
   */
  @NotNull 
  @JsonProperty("status")
  public StatusEnum getStatus() {
    return status;
  }

  @JsonProperty("status")
  public void setStatus(StatusEnum status) {
    this.status = status;
  }

  public MissingRequirementResult missingOptions(List<@Valid MissingOption> missingOptions) {
    this.missingOptions = missingOptions;
    return this;
  }

  public MissingRequirementResult addMissingOptionsItem(MissingOption missingOptionsItem) {
    if (this.missingOptions == null) {
      this.missingOptions = new ArrayList<>();
    }
    this.missingOptions.add(missingOptionsItem);
    return this;
  }

  /**
   * Get missingOptions
   * @return missingOptions
   */
  @NotNull @Valid @Size(min = 1) 
  @JsonProperty("missingOptions")
  public List<@Valid MissingOption> getMissingOptions() {
    return missingOptions;
  }

  @JsonProperty("missingOptions")
  public void setMissingOptions(List<@Valid MissingOption> missingOptions) {
    this.missingOptions = missingOptions;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    MissingRequirementResult missingRequirementResult = (MissingRequirementResult) o;
    return Objects.equals(this.status, missingRequirementResult.status) &&
        Objects.equals(this.missingOptions, missingRequirementResult.missingOptions);
  }

  @Override
  public int hashCode() {
    return Objects.hash(status, missingOptions);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class MissingRequirementResult {\n");
    sb.append("    status: ").append(toIndentedString(status)).append("\n");
    sb.append("    missingOptions: ").append(toIndentedString(missingOptions)).append("\n");
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

