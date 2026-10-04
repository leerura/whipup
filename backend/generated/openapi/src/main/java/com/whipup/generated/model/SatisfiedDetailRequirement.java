package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import com.whipup.generated.model.DetailRequirementOption;
import com.whipup.generated.model.IngredientMatch;
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
 * SatisfiedDetailRequirement
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class SatisfiedDetailRequirement implements DetailRequirement {

  /**
   * Gets or Sets status
   */
  public enum StatusEnum {
    SATISFIED("SATISFIED");

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

  private List<@Valid DetailRequirementOption> options = new ArrayList<>();

  private List<@Valid IngredientMatch> matches = new ArrayList<>();

  public SatisfiedDetailRequirement() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public SatisfiedDetailRequirement(StatusEnum status, List<@Valid DetailRequirementOption> options, List<@Valid IngredientMatch> matches) {
    this.status = status;
    this.options = options;
    this.matches = matches;
  }

  public SatisfiedDetailRequirement status(StatusEnum status) {
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

  public SatisfiedDetailRequirement options(List<@Valid DetailRequirementOption> options) {
    this.options = options;
    return this;
  }

  public SatisfiedDetailRequirement addOptionsItem(DetailRequirementOption optionsItem) {
    if (this.options == null) {
      this.options = new ArrayList<>();
    }
    this.options.add(optionsItem);
    return this;
  }

  /**
   * Get options
   * @return options
   */
  @NotNull @Valid @Size(min = 1) 
  @JsonProperty("options")
  public List<@Valid DetailRequirementOption> getOptions() {
    return options;
  }

  @JsonProperty("options")
  public void setOptions(List<@Valid DetailRequirementOption> options) {
    this.options = options;
  }

  public SatisfiedDetailRequirement matches(List<@Valid IngredientMatch> matches) {
    this.matches = matches;
    return this;
  }

  public SatisfiedDetailRequirement addMatchesItem(IngredientMatch matchesItem) {
    if (this.matches == null) {
      this.matches = new ArrayList<>();
    }
    this.matches.add(matchesItem);
    return this;
  }

  /**
   * Get matches
   * @return matches
   */
  @NotNull @Valid @Size(min = 1) 
  @JsonProperty("matches")
  public List<@Valid IngredientMatch> getMatches() {
    return matches;
  }

  @JsonProperty("matches")
  public void setMatches(List<@Valid IngredientMatch> matches) {
    this.matches = matches;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    SatisfiedDetailRequirement satisfiedDetailRequirement = (SatisfiedDetailRequirement) o;
    return Objects.equals(this.status, satisfiedDetailRequirement.status) &&
        Objects.equals(this.options, satisfiedDetailRequirement.options) &&
        Objects.equals(this.matches, satisfiedDetailRequirement.matches);
  }

  @Override
  public int hashCode() {
    return Objects.hash(status, options, matches);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class SatisfiedDetailRequirement {\n");
    sb.append("    status: ").append(toIndentedString(status)).append("\n");
    sb.append("    options: ").append(toIndentedString(options)).append("\n");
    sb.append("    matches: ").append(toIndentedString(matches)).append("\n");
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

