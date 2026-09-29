package com.whipup.ingredient.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "ingredient_variant_relation")
@IdClass(IngredientVariantRelationId.class)
public class IngredientVariantRelation {

    @Id
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "source_variant_id", nullable = false)
    private IngredientVariant sourceVariant;

    @Id
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "target_variant_id", nullable = false)
    private IngredientVariant targetVariant;

    protected IngredientVariantRelation() {
    }

    public static IngredientVariantRelation create(
        IngredientVariant sourceVariant,
        IngredientVariant targetVariant
    ) {
        IngredientVariantRelation relation = new IngredientVariantRelation();
        relation.sourceVariant = sourceVariant;
        relation.targetVariant = targetVariant;
        return relation;
    }

    public IngredientVariant getSourceVariant() {
        return sourceVariant;
    }

    public IngredientVariant getTargetVariant() {
        return targetVariant;
    }
}
