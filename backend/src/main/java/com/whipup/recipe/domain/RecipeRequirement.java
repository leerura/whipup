package com.whipup.recipe.domain;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recipe_requirement")
public class RecipeRequirement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_requirement_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @OneToMany(mappedBy = "requirement", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeRequirementOption> options = new ArrayList<>();

    protected RecipeRequirement() {
    }

    public static RecipeRequirement create(int displayOrder, List<RecipeRequirementOption> options) {
        RecipeRequirement requirement = new RecipeRequirement();
        requirement.displayOrder = displayOrder;
        options.forEach(option -> {
            option.assignRequirement(requirement);
            requirement.options.add(option);
        });
        return requirement;
    }

    void assignRecipe(Recipe recipe) {
        this.recipe = recipe;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public List<RecipeRequirementOption> getOptions() {
        return options;
    }
}
