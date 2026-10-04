package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.whipup.generated.model.IngredientGroup;
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
 * IngredientGroupListResponse
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class IngredientGroupListResponse {

  private List<@Valid IngredientGroup> groups = new ArrayList<>();

  public IngredientGroupListResponse() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public IngredientGroupListResponse(List<@Valid IngredientGroup> groups) {
    this.groups = groups;
  }

  public IngredientGroupListResponse groups(List<@Valid IngredientGroup> groups) {
    this.groups = groups;
    return this;
  }

  public IngredientGroupListResponse addGroupsItem(IngredientGroup groupsItem) {
    if (this.groups == null) {
      this.groups = new ArrayList<>();
    }
    this.groups.add(groupsItem);
    return this;
  }

  /**
   * Get groups
   * @return groups
   */
  @NotNull @Valid 
  @JsonProperty("groups")
  public List<@Valid IngredientGroup> getGroups() {
    return groups;
  }

  @JsonProperty("groups")
  public void setGroups(List<@Valid IngredientGroup> groups) {
    this.groups = groups;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    IngredientGroupListResponse ingredientGroupListResponse = (IngredientGroupListResponse) o;
    return Objects.equals(this.groups, ingredientGroupListResponse.groups);
  }

  @Override
  public int hashCode() {
    return Objects.hash(groups);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class IngredientGroupListResponse {\n");
    sb.append("    groups: ").append(toIndentedString(groups)).append("\n");
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

