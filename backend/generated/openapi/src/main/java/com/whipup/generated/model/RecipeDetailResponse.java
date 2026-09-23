package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.RecipeIngredient;
import com.whipup.generated.model.RecipeStep;
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.lang.Nullable;
import org.openapitools.jackson.nullable.JsonNullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import io.swagger.v3.oas.annotations.media.Schema;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * RecipeDetailResponse
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.19.0")
public class RecipeDetailResponse {

  private Long recipeId;

  private String name;

  private URI shortsReference;

  private URI thumbnailUrl;

  private Integer missingCount;

  @Valid
  private List<@Valid RecipeIngredient> ingredients = new ArrayList<>();

  @Valid
  private List<@Valid RecipeStep> steps = new ArrayList<>();

  public RecipeDetailResponse() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public RecipeDetailResponse(Long recipeId, String name, URI shortsReference, URI thumbnailUrl, Integer missingCount, List<@Valid RecipeIngredient> ingredients, List<@Valid RecipeStep> steps) {
    this.recipeId = recipeId;
    this.name = name;
    this.shortsReference = shortsReference;
    this.thumbnailUrl = thumbnailUrl;
    this.missingCount = missingCount;
    this.ingredients = ingredients;
    this.steps = steps;
  }

  public RecipeDetailResponse recipeId(Long recipeId) {
    this.recipeId = recipeId;
    return this;
  }

  /**
   * Get recipeId
   * @return recipeId
   */
  @NotNull 
  @Schema(name = "recipeId", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("recipeId")
  public Long getRecipeId() {
    return recipeId;
  }

  public void setRecipeId(Long recipeId) {
    this.recipeId = recipeId;
  }

  public RecipeDetailResponse name(String name) {
    this.name = name;
    return this;
  }

  /**
   * Get name
   * @return name
   */
  @NotNull 
  @Schema(name = "name", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("name")
  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public RecipeDetailResponse shortsReference(URI shortsReference) {
    this.shortsReference = shortsReference;
    return this;
  }

  /**
   * Get shortsReference
   * @return shortsReference
   */
  @NotNull @Valid 
  @Schema(name = "shortsReference", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("shortsReference")
  public URI getShortsReference() {
    return shortsReference;
  }

  public void setShortsReference(URI shortsReference) {
    this.shortsReference = shortsReference;
  }

  public RecipeDetailResponse thumbnailUrl(URI thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
    return this;
  }

  /**
   * Get thumbnailUrl
   * @return thumbnailUrl
   */
  @NotNull @Valid 
  @Schema(name = "thumbnailUrl", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("thumbnailUrl")
  public URI getThumbnailUrl() {
    return thumbnailUrl;
  }

  public void setThumbnailUrl(URI thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
  }

  public RecipeDetailResponse missingCount(Integer missingCount) {
    this.missingCount = missingCount;
    return this;
  }

  /**
   * Get missingCount
   * minimum: 0
   * @return missingCount
   */
  @NotNull @Min(value = 0) 
  @Schema(name = "missingCount", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("missingCount")
  public Integer getMissingCount() {
    return missingCount;
  }

  public void setMissingCount(Integer missingCount) {
    this.missingCount = missingCount;
  }

  public RecipeDetailResponse ingredients(List<@Valid RecipeIngredient> ingredients) {
    this.ingredients = ingredients;
    return this;
  }

  public RecipeDetailResponse addIngredientsItem(RecipeIngredient ingredientsItem) {
    if (this.ingredients == null) {
      this.ingredients = new ArrayList<>();
    }
    this.ingredients.add(ingredientsItem);
    return this;
  }

  /**
   * Get ingredients
   * @return ingredients
   */
  @NotNull @Valid 
  @Schema(name = "ingredients", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("ingredients")
  public List<@Valid RecipeIngredient> getIngredients() {
    return ingredients;
  }

  public void setIngredients(List<@Valid RecipeIngredient> ingredients) {
    this.ingredients = ingredients;
  }

  public RecipeDetailResponse steps(List<@Valid RecipeStep> steps) {
    this.steps = steps;
    return this;
  }

  public RecipeDetailResponse addStepsItem(RecipeStep stepsItem) {
    if (this.steps == null) {
      this.steps = new ArrayList<>();
    }
    this.steps.add(stepsItem);
    return this;
  }

  /**
   * Get steps
   * @return steps
   */
  @NotNull @Valid 
  @Schema(name = "steps", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("steps")
  public List<@Valid RecipeStep> getSteps() {
    return steps;
  }

  public void setSteps(List<@Valid RecipeStep> steps) {
    this.steps = steps;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    RecipeDetailResponse recipeDetailResponse = (RecipeDetailResponse) o;
    return Objects.equals(this.recipeId, recipeDetailResponse.recipeId) &&
        Objects.equals(this.name, recipeDetailResponse.name) &&
        Objects.equals(this.shortsReference, recipeDetailResponse.shortsReference) &&
        Objects.equals(this.thumbnailUrl, recipeDetailResponse.thumbnailUrl) &&
        Objects.equals(this.missingCount, recipeDetailResponse.missingCount) &&
        Objects.equals(this.ingredients, recipeDetailResponse.ingredients) &&
        Objects.equals(this.steps, recipeDetailResponse.steps);
  }

  @Override
  public int hashCode() {
    return Objects.hash(recipeId, name, shortsReference, thumbnailUrl, missingCount, ingredients, steps);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class RecipeDetailResponse {\n");
    sb.append("    recipeId: ").append(toIndentedString(recipeId)).append("\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
    sb.append("    shortsReference: ").append(toIndentedString(shortsReference)).append("\n");
    sb.append("    thumbnailUrl: ").append(toIndentedString(thumbnailUrl)).append("\n");
    sb.append("    missingCount: ").append(toIndentedString(missingCount)).append("\n");
    sb.append("    ingredients: ").append(toIndentedString(ingredients)).append("\n");
    sb.append("    steps: ").append(toIndentedString(steps)).append("\n");
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

