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
@Table(name = "recipe_step")
public class RecipeStep {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_step_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(name = "step_order", nullable = false)
    private int stepOrder;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    protected RecipeStep() {
    }

    public static RecipeStep create(int stepOrder, String content) {
        RecipeStep recipeStep = new RecipeStep();
        recipeStep.stepOrder = stepOrder;
        recipeStep.content = content;
        return recipeStep;
    }

    void assignRecipe(Recipe recipe) {
        this.recipe = recipe;
    }

    public int getStepOrder() {
        return stepOrder;
    }

    public String getContent() {
        return content;
    }
}
