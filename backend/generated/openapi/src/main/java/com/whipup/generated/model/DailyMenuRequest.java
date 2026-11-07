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
 * DailyMenuRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class DailyMenuRequest {

  private Long recipeId;

  public DailyMenuRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public DailyMenuRequest(Long recipeId) {
    this.recipeId = recipeId;
  }

  public DailyMenuRequest recipeId(Long recipeId) {
    this.recipeId = recipeId;
    return this;
  }

  /**
   * Get recipeId
   * @return recipeId
   */
  @NotNull 
  @JsonProperty("recipeId")
  public Long getRecipeId() {
    return recipeId;
  }

  @JsonProperty("recipeId")
  public void setRecipeId(Long recipeId) {
    this.recipeId = recipeId;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    DailyMenuRequest dailyMenuRequest = (DailyMenuRequest) o;
    return Objects.equals(this.recipeId, dailyMenuRequest.recipeId);
  }

  @Override
  public int hashCode() {
    return Objects.hash(recipeId);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class DailyMenuRequest {\n");
    sb.append("    recipeId: ").append(toIndentedString(recipeId)).append("\n");
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

