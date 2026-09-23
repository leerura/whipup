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
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * RecommendationPage
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class RecommendationPage {

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
  @JsonProperty("items")
  public List<@Valid RecommendationItem> getItems() {
    return items;
  }

  @JsonProperty("items")
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
  @JsonProperty("page")
  public Integer getPage() {
    return page;
  }

  @JsonProperty("page")
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
  @JsonProperty("size")
  public Integer getSize() {
    return size;
  }

  @JsonProperty("size")
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
  @JsonProperty("hasNext")
  public Boolean getHasNext() {
    return hasNext;
  }

  @JsonProperty("hasNext")
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
    return o == null ? "null" : o.toString().replace("\n", "\n    ");
  }
}

