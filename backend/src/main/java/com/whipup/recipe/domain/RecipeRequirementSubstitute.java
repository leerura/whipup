package com.whipup.recipe.domain;

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
@Table(name = "recipe_requirement_substitute")
public class RecipeRequirementSubstitute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_requirement_substitute_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_requirement_option_id", nullable = false)
    private RecipeRequirementOption option;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_ingredient_id", nullable = false)
    private RecipeIngredient ingredient;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    protected RecipeRequirementSubstitute() {
    }

    public static RecipeRequirementSubstitute create(RecipeIngredient ingredient, int displayOrder) {
        RecipeRequirementSubstitute substitute = new RecipeRequirementSubstitute();
        substitute.ingredient = ingredient;
        substitute.displayOrder = displayOrder;
        return substitute;
    }

    void assignOption(RecipeRequirementOption option) {
        this.option = option;
    }

    public RecipeIngredient getIngredient() {
        return ingredient;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }
}
