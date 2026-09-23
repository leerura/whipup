package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.RecommendationItem;
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
 * RecommendationPage
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-09-23T01:37:49.076375542Z[Etc/UTC]", comments = "Generator version: 7.19.0")
public class RecommendationPage {

  @Valid
  private List<@Valid RecommendationItem> items = new ArrayList<>();

  private Integer page;

  private Integer size;

  private Boolean hasNext;

  public RecommendationPage() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public RecommendationPage(List<@Valid RecommendationItem> items, Integer page, Integer size, Boolean hasNext) {
    this.items = items;
    this.page = page;
    this.size = size;
    this.hasNext = hasNext;
  }

  public RecommendationPage items(List<@Valid RecommendationItem> items) {
    this.items = items;
    return this;
  }

  public RecommendationPage addItemsItem(RecommendationItem itemsItem) {
    if (this.items == null) {
      this.items = new ArrayList<>();
    }
    this.items.add(itemsItem);
    return this;
  }

  /**
   * Get items
   * @return items
   */
  @NotNull @Valid 
  @Schema(name = "items", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("items")
  public List<@Valid RecommendationItem> getItems() {
    return items;
  }

  public void setItems(List<@Valid RecommendationItem> items) {
    this.items = items;
  }

  public RecommendationPage page(Integer page) {
    this.page = page;
    return this;
  }

  /**
   * Get page
   * @return page
   */
  @NotNull 
  @Schema(name = "page", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("page")
  public Integer getPage() {
    return page;
  }

  public void setPage(Integer page) {
    this.page = page;
  }

  public RecommendationPage size(Integer size) {
    this.size = size;
    return this;
  }

  /**
   * Get size
   * @return size
   */
  @NotNull 
  @Schema(name = "size", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("size")
  public Integer getSize() {
    return size;
  }

  public void setSize(Integer size) {
    this.size = size;
  }

  public RecommendationPage hasNext(Boolean hasNext) {
    this.hasNext = hasNext;
    return this;
  }

  /**
   * Get hasNext
   * @return hasNext
   */
  @NotNull 
  @Schema(name = "hasNext", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("hasNext")
  public Boolean getHasNext() {
    return hasNext;
  }

  public void setHasNext(Boolean hasNext) {
    this.hasNext = hasNext;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    RecommendationPage recommendationPage = (RecommendationPage) o;
    return Objects.equals(this.items, recommendationPage.items) &&
        Objects.equals(this.page, recommendationPage.page) &&
        Objects.equals(this.size, recommendationPage.size) &&
        Objects.equals(this.hasNext, recommendationPage.hasNext);
  }

  @Override
  public int hashCode() {
    return Objects.hash(items, page, size, hasNext);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class RecommendationPage {\n");
    sb.append("    items: ").append(toIndentedString(items)).append("\n");
    sb.append("    page: ").append(toIndentedString(page)).append("\n");
    sb.append("    size: ").append(toIndentedString(size)).append("\n");
    sb.append("    hasNext: ").append(toIndentedString(hasNext)).append("\n");
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

