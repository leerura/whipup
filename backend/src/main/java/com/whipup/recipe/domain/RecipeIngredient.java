package com.whipup.recipe.domain;

import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.domain.IngredientVariant;
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
    @JoinColumn(name = "ingredient_variant_id")
    private IngredientVariant ingredientVariant;

    @Column(name = "display_name", nullable = false)
    private String displayName;

    @Column(name = "raw_text", nullable = false, columnDefinition = "TEXT")
    private String rawText;

    private String amount;

    private String unit;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @Column(name = "is_optional", nullable = false)
    private boolean optional;

    protected RecipeIngredient() {
    }

    public static RecipeIngredient create(
        IngredientVariant ingredientVariant,
        String displayName,
        String rawText,
        String amount,
        String unit,
        int displayOrder,
        boolean optional
    ) {
        RecipeIngredient recipeIngredient = new RecipeIngredient();
        recipeIngredient.ingredientVariant = ingredientVariant;
        recipeIngredient.displayName = displayName;
        recipeIngredient.rawText = rawText;
        recipeIngredient.amount = amount;
        recipeIngredient.unit = unit;
        recipeIngredient.displayOrder = displayOrder;
        recipeIngredient.optional = optional;
        return recipeIngredient;
    }

    public static RecipeIngredient create(
        Ingredient ingredient,
        String displayName,
        String rawText,
        String amount,
        String unit,
        int displayOrder
    ) {
        return create(null, displayName, rawText, amount, unit, displayOrder, false);
    }

    void assignRecipe(Recipe recipe) {
        this.recipe = recipe;
    }

    public Long getId() {
        return id;
    }

    public Ingredient getIngredient() {
        return ingredientVariant == null ? null : ingredientVariant.getIngredient();
    }

    public IngredientVariant getIngredientVariant() {
        return ingredientVariant;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getRawText() {
        return rawText;
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

    public boolean isOptional() {
        return optional;
    }
}
