package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.OwnedIngredient;
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
 * OwnedIngredientListResponse
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class OwnedIngredientListResponse {

  private List<@Valid OwnedIngredient> items = new ArrayList<>();

  public OwnedIngredientListResponse() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public OwnedIngredientListResponse(List<@Valid OwnedIngredient> items) {
    this.items = items;
  }

  public OwnedIngredientListResponse items(List<@Valid OwnedIngredient> items) {
    this.items = items;
    return this;
  }

  public OwnedIngredientListResponse addItemsItem(OwnedIngredient itemsItem) {
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
  public List<@Valid OwnedIngredient> getItems() {
    return items;
  }

  @JsonProperty("items")
  public void setItems(List<@Valid OwnedIngredient> items) {
    this.items = items;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    OwnedIngredientListResponse ownedIngredientListResponse = (OwnedIngredientListResponse) o;
    return Objects.equals(this.items, ownedIngredientListResponse.items);
  }

  @Override
  public int hashCode() {
    return Objects.hash(items);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class OwnedIngredientListResponse {\n");
    sb.append("    items: ").append(toIndentedString(items)).append("\n");
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

