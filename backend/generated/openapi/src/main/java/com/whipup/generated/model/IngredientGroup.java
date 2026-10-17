package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.IngredientVariantOption;
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
 * IngredientGroup
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class IngredientGroup {

  private String name;

  private List<@Valid IngredientVariantOption> items = new ArrayList<>();

  public IngredientGroup() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public IngredientGroup(String name, List<@Valid IngredientVariantOption> items) {
    this.name = name;
    this.items = items;
  }

  public IngredientGroup name(String name) {
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

  public IngredientGroup items(List<@Valid IngredientVariantOption> items) {
    this.items = items;
    return this;
  }

  public IngredientGroup addItemsItem(IngredientVariantOption itemsItem) {
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
  @JsonProperty("items")
  public List<@Valid IngredientVariantOption> getItems() {
    return items;
  }

  @JsonProperty("items")
  public void setItems(List<@Valid IngredientVariantOption> items) {
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
    IngredientGroup ingredientGroup = (IngredientGroup) o;
    return Objects.equals(this.name, ingredientGroup.name) &&
        Objects.equals(this.items, ingredientGroup.items);
  }

  @Override
  public int hashCode() {
    return Objects.hash(name, items);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class IngredientGroup {\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
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

