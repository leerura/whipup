package com.whipup.generated.model;

import java.net.URI;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import org.springframework.lang.Nullable;
import java.time.OffsetDateTime;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;


import java.util.*;
import jakarta.annotation.Generated;

/**
 * HttpTimingRequest
 */

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
public class HttpTimingRequest {

  /**
   * Gets or Sets route
   */
  public enum RouteEnum {
    _API_V1_AUTH_GUEST("/api/v1/auth/guest"),
    
    _API_V1_ME("/api/v1/me"),
    
    _API_V1_ME_TERMS_CONSENT("/api/v1/me/terms-consent"),
    
    _API_V1_ME_ONBOARDING("/api/v1/me/onboarding"),
    
    _API_V1_RECIPES_RECOMMENDATIONS("/api/v1/recipes/recommendations"),
    
    _API_V1_RECIPES_SEARCH("/api/v1/recipes/search"),
    
    _API_V1_RECIPES_RECIPE_ID_("/api/v1/recipes/{recipeId}"),
    
    _API_V1_ME_DAILY_MENU("/api/v1/me/daily-menu"),
    
    _API_V1_ME_DAILY_MENU_RECIPE_ID_("/api/v1/me/daily-menu/{recipeId}"),
    
    _API_V1_ME_INGREDIENTS("/api/v1/me/ingredients"),
    
    _API_V1_ME_INGREDIENTS_USER_INGREDIENT_ID_("/api/v1/me/ingredients/{userIngredientId}"),
    
    _API_V1_INGREDIENTS("/api/v1/ingredients");

    private final String value;

    RouteEnum(String value) {
      this.value = value;
    }

    @JsonValue
    public String getValue() {
      return value;
    }

    @Override
    public String toString() {
      return String.valueOf(value);
    }

    @JsonCreator
    public static RouteEnum fromValue(String value) {
      for (RouteEnum b : RouteEnum.values()) {
        if (b.value.equals(value)) {
          return b;
        }
      }
      throw new IllegalArgumentException("Unexpected value '" + value + "'");
    }
  }

  private RouteEnum route;

  /**
   * Gets or Sets method
   */
  public enum MethodEnum {
    GET("GET"),
    
    POST("POST"),
    
    DELETE("DELETE");

    private final String value;

    MethodEnum(String value) {
      this.value = value;
    }

    @JsonValue
    public String getValue() {
      return value;
    }

    @Override
    public String toString() {
      return String.valueOf(value);
    }

    @JsonCreator
    public static MethodEnum fromValue(String value) {
      for (MethodEnum b : MethodEnum.values()) {
        if (b.value.equals(value)) {
          return b;
        }
      }
      throw new IllegalArgumentException("Unexpected value '" + value + "'");
    }
  }

  private MethodEnum method;

  /**
   * Gets or Sets outcome
   */
  public enum OutcomeEnum {
    SUCCESS("SUCCESS"),
    
    CLIENT_ERROR("CLIENT_ERROR"),
    
    SERVER_ERROR("SERVER_ERROR"),
    
    NETWORK_ERROR("NETWORK_ERROR");

    private final String value;

    OutcomeEnum(String value) {
      this.value = value;
    }

    @JsonValue
    public String getValue() {
      return value;
    }

    @Override
    public String toString() {
      return String.valueOf(value);
    }

    @JsonCreator
    public static OutcomeEnum fromValue(String value) {
      for (OutcomeEnum b : OutcomeEnum.values()) {
        if (b.value.equals(value)) {
          return b;
        }
      }
      throw new IllegalArgumentException("Unexpected value '" + value + "'");
    }
  }

  private OutcomeEnum outcome;

  private Integer durationMs;

  public HttpTimingRequest() {
    super();
  }

  /**
   * Constructor with only required parameters
   */
  public HttpTimingRequest(RouteEnum route, MethodEnum method, OutcomeEnum outcome, Integer durationMs) {
    this.route = route;
    this.method = method;
    this.outcome = outcome;
    this.durationMs = durationMs;
  }

  public HttpTimingRequest route(RouteEnum route) {
    this.route = route;
    return this;
  }

  /**
   * Get route
   * @return route
   */
  @NotNull 
  @JsonProperty("route")
  public RouteEnum getRoute() {
    return route;
  }

  @JsonProperty("route")
  public void setRoute(RouteEnum route) {
    this.route = route;
  }

  public HttpTimingRequest method(MethodEnum method) {
    this.method = method;
    return this;
  }

  /**
   * Get method
   * @return method
   */
  @NotNull 
  @JsonProperty("method")
  public MethodEnum getMethod() {
    return method;
  }

  @JsonProperty("method")
  public void setMethod(MethodEnum method) {
    this.method = method;
  }

  public HttpTimingRequest outcome(OutcomeEnum outcome) {
    this.outcome = outcome;
    return this;
  }

  /**
   * Get outcome
   * @return outcome
   */
  @NotNull 
  @JsonProperty("outcome")
  public OutcomeEnum getOutcome() {
    return outcome;
  }

  @JsonProperty("outcome")
  public void setOutcome(OutcomeEnum outcome) {
    this.outcome = outcome;
  }

  public HttpTimingRequest durationMs(Integer durationMs) {
    this.durationMs = durationMs;
    return this;
  }

  /**
   * Get durationMs
   * minimum: 0
   * maximum: 60000
   * @return durationMs
   */
  @NotNull @Min(value = 0) @Max(value = 60000) 
  @JsonProperty("durationMs")
  public Integer getDurationMs() {
    return durationMs;
  }

  @JsonProperty("durationMs")
  public void setDurationMs(Integer durationMs) {
    this.durationMs = durationMs;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    HttpTimingRequest httpTimingRequest = (HttpTimingRequest) o;
    return Objects.equals(this.route, httpTimingRequest.route) &&
        Objects.equals(this.method, httpTimingRequest.method) &&
        Objects.equals(this.outcome, httpTimingRequest.outcome) &&
        Objects.equals(this.durationMs, httpTimingRequest.durationMs);
  }

  @Override
  public int hashCode() {
    return Objects.hash(route, method, outcome, durationMs);
  }

  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class HttpTimingRequest {\n");
    sb.append("    route: ").append(toIndentedString(route)).append("\n");
    sb.append("    method: ").append(toIndentedString(method)).append("\n");
    sb.append("    outcome: ").append(toIndentedString(outcome)).append("\n");
    sb.append("    durationMs: ").append(toIndentedString(durationMs)).append("\n");
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

