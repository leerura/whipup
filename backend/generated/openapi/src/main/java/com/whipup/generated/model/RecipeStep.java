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
 * RecipeStep
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.19.0")
public class RecipeStep {

  private Integer order;

  private String content;

  public RecipeStep() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public RecipeStep(Integer order, String content) {
    this.order = order;
    this.content = content;
  }

  public RecipeStep order(Integer order) {
    this.order = order;
    return this;
  }

  /**
   * Get order
   * minimum: 1
   * @return order
   */
  @NotNull @Min(value = 1) 
  @Schema(name = "order", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("order")
  public Integer getOrder() {
    return order;
  }

  public void setOrder(Integer order) {
    this.order = order;
  }

  public RecipeStep content(String content) {
    this.content = content;
    return this;
  }

  /**
   * Get content
   * @return content
   */
  @NotNull 
  @Schema(name = "content", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("content")
  public String getContent() {
    return content;
  }

  public void setContent(String content) {
    this.content = content;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    RecipeStep recipeStep = (RecipeStep) o;
    return Objects.equals(this.order, recipeStep.order) &&
        Objects.equals(this.content, recipeStep.content);
  }

  @Override
  public int hashCode() {
    return Objects.hash(order, content);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class RecipeStep {\n");
    sb.append("    order: ").append(toIndentedString(order)).append("\n");
    sb.append("    content: ").append(toIndentedString(content)).append("\n");
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

