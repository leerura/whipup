package com.whipup.ingredient.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
    name = "ingredient_variant",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_ingredient_variant_ingredient_name",
        columnNames = { "ingredient_id", "name" }
    )
)
public class IngredientVariant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ingredient_variant_id")
    private Long id;

    @Column(name = "key", nullable = false, unique = true, length = 255)
    private String key;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ingredient_id", nullable = false)
    private Ingredient ingredient;

    @Column(nullable = false, length = 255)
    private String name;

    @Column(name = "is_base", nullable = false)
    private boolean base;

    protected IngredientVariant() {
    }

    public static IngredientVariant create(
        String key,
        Ingredient ingredient,
        String name,
        boolean base
    ) {
        IngredientVariant variant = new IngredientVariant();
        variant.key = key;
        variant.ingredient = ingredient;
        variant.name = name;
        variant.base = base;
        return variant;
    }

    public void update(Ingredient ingredient, String name, boolean base) {
        this.ingredient = ingredient;
        this.name = name;
        this.base = base;
    }

    public Long getId() {
        return id;
    }

    public String getKey() {
        return key;
    }

    public Ingredient getIngredient() {
        return ingredient;
    }

    public String getName() {
        return name;
    }

    public boolean isBase() {
        return base;
    }
}
