package com.whipup.recipe.domain;

import com.whipup.ingredient.domain.Ingredient;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "recipe_ingredient")
public class RecipeIngredient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_ingredient_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ingredient_id")
    private Ingredient ingredient;

    @Column(name = "display_name", nullable = false)
    private String displayName;

    @Column(name = "raw_text", nullable = false, columnDefinition = "TEXT")
    private String rawText;

    private String amount;

    private String unit;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    protected RecipeIngredient() {
    }

    public static RecipeIngredient create(
        Ingredient ingredient,
        String displayName,
        String rawText,
        String amount,
        String unit,
        int displayOrder
    ) {
        RecipeIngredient recipeIngredient = new RecipeIngredient();
        recipeIngredient.ingredient = ingredient;
        recipeIngredient.displayName = displayName;
        recipeIngredient.rawText = rawText;
        recipeIngredient.amount = amount;
        recipeIngredient.unit = unit;
        recipeIngredient.displayOrder = displayOrder;
        return recipeIngredient;
    }

    void assignRecipe(Recipe recipe) {
        this.recipe = recipe;
    }

    public Long getId() {
        return id;
    }

    public Ingredient getIngredient() {
        return ingredient;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getAmount() {
        return amount;
    }

    public String getUnit() {
        return unit;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }
}
