package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import com.whipup.generated.model.MissingIngredient;
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
 * RecommendationItem
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class RecommendationItem {

  private Long recipeId;

  private String name;

  private URI thumbnailUrl;

  /**
   * Gets or Sets missingCount
   */
  public enum MissingCountEnum {
    NUMBER_0(0),
    
    NUMBER_1(1),
    
    NUMBER_2(2);

    private final Integer value;

    MissingCountEnum(Integer value) {
      this.value = value;
    }

    @JsonValue
    public Integer getValue() {
      return value;
    }

    @Override
    public String toString() {
      return String.valueOf(value);
    }

    @JsonCreator
    public static MissingCountEnum fromValue(Integer value) {
      for (MissingCountEnum b : MissingCountEnum.values()) {
        if (b.value.equals(value)) {
          return b;
        }
      }
      throw new IllegalArgumentException("Unexpected value '" + value + "'");
    }
  }

  private MissingCountEnum missingCount;

  private List<@Valid MissingIngredient> missingIngredients = new ArrayList<>();

  public RecommendationItem() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public RecommendationItem(Long recipeId, String name, URI thumbnailUrl, MissingCountEnum missingCount, List<@Valid MissingIngredient> missingIngredients) {
    this.recipeId = recipeId;
    this.name = name;
    this.thumbnailUrl = thumbnailUrl;
    this.missingCount = missingCount;
    this.missingIngredients = missingIngredients;
  }

  public RecommendationItem recipeId(Long recipeId) {
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

  @JsonProperty("recipeId")
  public void setRecipeId(Long recipeId) {
    this.recipeId = recipeId;
  }

  public RecommendationItem name(String name) {
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

  @JsonProperty("name")
  public void setName(String name) {
    this.name = name;
  }

  public RecommendationItem thumbnailUrl(URI thumbnailUrl) {
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

  @JsonProperty("thumbnailUrl")
  public void setThumbnailUrl(URI thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
  }

  public RecommendationItem missingCount(MissingCountEnum missingCount) {
    this.missingCount = missingCount;
    return this;
  }

  /**
   * Get missingCount
   * @return missingCount
   */
  @NotNull 
  @Schema(name = "missingCount", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("missingCount")
  public MissingCountEnum getMissingCount() {
    return missingCount;
  }

  @JsonProperty("missingCount")
  public void setMissingCount(MissingCountEnum missingCount) {
    this.missingCount = missingCount;
  }

  public RecommendationItem missingIngredients(List<@Valid MissingIngredient> missingIngredients) {
    this.missingIngredients = missingIngredients;
    return this;
  }

  public RecommendationItem addMissingIngredientsItem(MissingIngredient missingIngredientsItem) {
    if (this.missingIngredients == null) {
      this.missingIngredients = new ArrayList<>();
    }
    this.missingIngredients.add(missingIngredientsItem);
    return this;
  }

  /**
   * Get missingIngredients
   * @return missingIngredients
   */
  @NotNull @Valid 
  @Schema(name = "missingIngredients", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("missingIngredients")
  public List<@Valid MissingIngredient> getMissingIngredients() {
    return missingIngredients;
  }

  @JsonProperty("missingIngredients")
  public void setMissingIngredients(List<@Valid MissingIngredient> missingIngredients) {
    this.missingIngredients = missingIngredients;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    RecommendationItem recommendationItem = (RecommendationItem) o;
    return Objects.equals(this.recipeId, recommendationItem.recipeId) &&
        Objects.equals(this.name, recommendationItem.name) &&
        Objects.equals(this.thumbnailUrl, recommendationItem.thumbnailUrl) &&
        Objects.equals(this.missingCount, recommendationItem.missingCount) &&
        Objects.equals(this.missingIngredients, recommendationItem.missingIngredients);
  }

  @Override
  public int hashCode() {
    return Objects.hash(recipeId, name, thumbnailUrl, missingCount, missingIngredients);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class RecommendationItem {\n");
    sb.append("    recipeId: ").append(toIndentedString(recipeId)).append("\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
    sb.append("    thumbnailUrl: ").append(toIndentedString(thumbnailUrl)).append("\n");
    sb.append("    missingCount: ").append(toIndentedString(missingCount)).append("\n");
    sb.append("    missingIngredients: ").append(toIndentedString(missingIngredients)).append("\n");
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

