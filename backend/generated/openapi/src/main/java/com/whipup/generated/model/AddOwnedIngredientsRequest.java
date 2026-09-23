package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.OwnedIngredientSelection;
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
 * AddOwnedIngredientsRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-09-23T01:37:49.076375542Z[Etc/UTC]", comments = "Generator version: 7.19.0")
public class AddOwnedIngredientsRequest {

  @Valid
  private List<@Valid OwnedIngredientSelection> items = new ArrayList<>();

  public AddOwnedIngredientsRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public AddOwnedIngredientsRequest(List<@Valid OwnedIngredientSelection> items) {
    this.items = items;
  }

  public AddOwnedIngredientsRequest items(List<@Valid OwnedIngredientSelection> items) {
    this.items = items;
    return this;
  }

  public AddOwnedIngredientsRequest addItemsItem(OwnedIngredientSelection itemsItem) {
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
  @NotNull @Valid @Size(min = 1) 
  @Schema(name = "items", requiredMode = Schema.RequiredMode.REQUIRED)
  @JsonProperty("items")
  public List<@Valid OwnedIngredientSelection> getItems() {
    return items;
  }

  public void setItems(List<@Valid OwnedIngredientSelection> items) {
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
    AddOwnedIngredientsRequest addOwnedIngredientsRequest = (AddOwnedIngredientsRequest) o;
    return Objects.equals(this.items, addOwnedIngredientsRequest.items);
  }

  @Override
  public int hashCode() {
    return Objects.hash(items);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class AddOwnedIngredientsRequest {\n");
    sb.append("    items: ").append(toIndentedString(items)).append("\n");
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

