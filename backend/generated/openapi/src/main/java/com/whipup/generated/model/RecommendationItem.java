package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.RequirementResult;
import java.net.URI;
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
 * RecommendationItem
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class RecommendationItem {

  private Long recipeId;

  private String name;

  private URI thumbnailUrl;

  private Integer missingCount;

  private List<RequirementResult> requirementResults = new ArrayList<>();

  public RecommendationItem() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public RecommendationItem(Long recipeId, String name, URI thumbnailUrl, Integer missingCount, List<RequirementResult> requirementResults) {
    this.recipeId = recipeId;
    this.name = name;
    this.thumbnailUrl = thumbnailUrl;
    this.missingCount = missingCount;
    this.requirementResults = requirementResults;
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
  @JsonProperty("thumbnailUrl")
  public URI getThumbnailUrl() {
    return thumbnailUrl;
  }

  @JsonProperty("thumbnailUrl")
  public void setThumbnailUrl(URI thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
  }

  public RecommendationItem missingCount(Integer missingCount) {
    this.missingCount = missingCount;
    return this;
  }

  /**
   * Get missingCount
   * minimum: 0
   * @return missingCount
   */
  @NotNull @Min(value = 0) 
  @JsonProperty("missingCount")
  public Integer getMissingCount() {
    return missingCount;
  }

  @JsonProperty("missingCount")
  public void setMissingCount(Integer missingCount) {
    this.missingCount = missingCount;
  }

  public RecommendationItem requirementResults(List<RequirementResult> requirementResults) {
    this.requirementResults = requirementResults;
    return this;
  }

  public RecommendationItem addRequirementResultsItem(RequirementResult requirementResultsItem) {
    if (this.requirementResults == null) {
      this.requirementResults = new ArrayList<>();
    }
    this.requirementResults.add(requirementResultsItem);
    return this;
  }

  /**
   * Get requirementResults
   * @return requirementResults
   */
  @NotNull @Valid 
  @JsonProperty("requirementResults")
  public List<RequirementResult> getRequirementResults() {
    return requirementResults;
  }

  @JsonProperty("requirementResults")
  public void setRequirementResults(List<RequirementResult> requirementResults) {
    this.requirementResults = requirementResults;
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
        Objects.equals(this.requirementResults, recommendationItem.requirementResults);
  }

  @Override
  public int hashCode() {
    return Objects.hash(recipeId, name, thumbnailUrl, missingCount, requirementResults);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class RecommendationItem {\n");
    sb.append("    recipeId: ").append(toIndentedString(recipeId)).append("\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
    sb.append("    thumbnailUrl: ").append(toIndentedString(thumbnailUrl)).append("\n");
    sb.append("    missingCount: ").append(toIndentedString(missingCount)).append("\n");
    sb.append("    requirementResults: ").append(toIndentedString(requirementResults)).append("\n");
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

