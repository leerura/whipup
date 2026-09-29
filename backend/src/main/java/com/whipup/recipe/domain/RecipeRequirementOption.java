package com.whipup.recipe.domain;

import com.whipup.ingredient.domain.IngredientVariant;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recipe_requirement_option")
public class RecipeRequirementOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_requirement_option_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_requirement_id", nullable = false)
    private RecipeRequirement requirement;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recipe_ingredient_id", nullable = false)
    private RecipeIngredient ingredient;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @OneToMany(mappedBy = "option", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeRequirementSubstitute> substitutes = new ArrayList<>();

    @ManyToMany
    @JoinTable(
        name = "recipe_requirement_allowed_variant",
        joinColumns = @JoinColumn(name = "recipe_requirement_option_id"),
        inverseJoinColumns = @JoinColumn(name = "ingredient_variant_id")
    )
    private List<IngredientVariant> allowedVariants = new ArrayList<>();

    protected RecipeRequirementOption() {
    }

    public static RecipeRequirementOption create(
        RecipeIngredient ingredient,
        int displayOrder,
        List<RecipeRequirementSubstitute> substitutes,
        List<IngredientVariant> allowedVariants
    ) {
        RecipeRequirementOption option = new RecipeRequirementOption();
        option.ingredient = ingredient;
        option.displayOrder = displayOrder;
        substitutes.forEach(substitute -> {
            substitute.assignOption(option);
            option.substitutes.add(substitute);
        });
        option.allowedVariants.addAll(allowedVariants);
        return option;
    }

    void assignRequirement(RecipeRequirement requirement) {
        this.requirement = requirement;
    }

    public RecipeIngredient getIngredient() {
        return ingredient;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public List<RecipeRequirementSubstitute> getSubstitutes() {
        return substitutes;
    }

    public List<IngredientVariant> getAllowedVariants() {
        return allowedVariants;
    }
}
