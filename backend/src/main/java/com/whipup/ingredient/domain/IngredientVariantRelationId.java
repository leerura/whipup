package com.whipup.ingredient.domain;

import java.io.Serializable;
import java.util.Objects;

public class IngredientVariantRelationId implements Serializable {

    private Long sourceVariant;
    private Long targetVariant;

    protected IngredientVariantRelationId() {
    }

    public IngredientVariantRelationId(Long sourceVariant, Long targetVariant) {
        this.sourceVariant = sourceVariant;
        this.targetVariant = targetVariant;
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof IngredientVariantRelationId that)) {
            return false;
        }
        return Objects.equals(sourceVariant, that.sourceVariant)
            && Objects.equals(targetVariant, that.targetVariant);
    }

    @Override
    public int hashCode() {
        return Objects.hash(sourceVariant, targetVariant);
    }
}
