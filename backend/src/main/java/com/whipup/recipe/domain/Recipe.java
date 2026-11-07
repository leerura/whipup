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

    @Column(name = "source_title", length = 2048)
    private String sourceTitle;

    @Column(name = "source_channel_name", length = 512)
    private String sourceChannelName;

    @Column(name = "source_channel_id", length = 128)
    private String sourceChannelId;

    @Column(name = "source_metadata_fetched_at")
    private OffsetDateTime sourceMetadataFetchedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeIngredient> ingredients = new ArrayList<>();

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeStep> steps = new ArrayList<>();

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeRequirement> requirements = new ArrayList<>();

    protected Recipe() {
    }

    public static Recipe createPublished(String datasetKey, String name, String shortsReference) {
        return create(datasetKey, name, RecipeStatus.PUBLISHED, shortsReference, null, null, null, null);
    }

    public static Recipe create(String datasetKey, String name, RecipeStatus status, String shortsReference) {
        return create(datasetKey, name, status, shortsReference, null, null, null, null);
    }

    public static Recipe create(String datasetKey, String name, RecipeStatus status, String shortsReference,
            String sourceTitle, String sourceChannelName, String sourceChannelId, OffsetDateTime sourceMetadataFetchedAt) {
        Recipe recipe = new Recipe();
        recipe.datasetKey = datasetKey;
        recipe.name = name;
        recipe.status = status;
        recipe.shortsReference = shortsReference;
        recipe.updateSourceMetadata(sourceTitle, sourceChannelName, sourceChannelId, sourceMetadataFetchedAt);
        return recipe;
    }

    public void updatePublished(String name, String shortsReference) {
        update(name, RecipeStatus.PUBLISHED, shortsReference);
    }

    public void update(String name, RecipeStatus status, String shortsReference) {
        this.name = name;
        this.status = status;
        this.shortsReference = shortsReference;
    }

    public void updateSourceMetadata(String title, String channelName, String channelId, OffsetDateTime fetchedAt) {
        this.sourceTitle = title;
        this.sourceChannelName = channelName;
        this.sourceChannelId = channelId;
        this.sourceMetadataFetchedAt = fetchedAt;
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

    public void replaceRequirements(List<RecipeRequirement> requirements) {
        this.requirements.clear();
        requirements.forEach(requirement -> {
            requirement.assignRecipe(this);
            this.requirements.add(requirement);
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

    public String getSourceTitle() { return sourceTitle; }
    public String getSourceChannelName() { return sourceChannelName; }
    public String getSourceChannelId() { return sourceChannelId; }
    public OffsetDateTime getSourceMetadataFetchedAt() { return sourceMetadataFetchedAt; }

    public List<RecipeIngredient> getIngredients() {
        return ingredients;
    }

    public List<RecipeStep> getSteps() {
        return steps;
    }

    public List<RecipeRequirement> getRequirements() {
        return requirements;
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
