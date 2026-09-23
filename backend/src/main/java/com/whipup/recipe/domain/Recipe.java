package com.whipup.recipe.domain;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recipe")
public class Recipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_id")
    private Long id;

    @Column(name = "dataset_key", nullable = false, unique = true)
    private String datasetKey;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RecipeStatus status;

    @Column(name = "shorts_reference", nullable = false, length = 2048)
    private String shortsReference;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeIngredient> ingredients = new ArrayList<>();

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeStep> steps = new ArrayList<>();

    protected Recipe() {
    }

    public static Recipe createPublished(String datasetKey, String name, String shortsReference) {
        Recipe recipe = new Recipe();
        recipe.datasetKey = datasetKey;
        recipe.name = name;
        recipe.status = RecipeStatus.PUBLISHED;
        recipe.shortsReference = shortsReference;
        return recipe;
    }

    public void updatePublished(String name, String shortsReference) {
        this.name = name;
        this.status = RecipeStatus.PUBLISHED;
        this.shortsReference = shortsReference;
    }

    public void replaceIngredients(List<RecipeIngredient> ingredients) {
        this.ingredients.clear();
        ingredients.forEach(ingredient -> {
            ingredient.assignRecipe(this);
            this.ingredients.add(ingredient);
        });
    }

    public void replaceSteps(List<RecipeStep> steps) {
        this.steps.clear();
        steps.forEach(step -> {
            step.assignRecipe(this);
            this.steps.add(step);
        });
    }

    public String getDatasetKey() {
        return datasetKey;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public RecipeStatus getStatus() {
        return status;
    }

    public String getShortsReference() {
        return shortsReference;
    }

    public List<RecipeIngredient> getIngredients() {
        return ingredients;
    }

    public List<RecipeStep> getSteps() {
        return steps;
    }

    @PrePersist
    void onCreate() {
        OffsetDateTime now = OffsetDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}
