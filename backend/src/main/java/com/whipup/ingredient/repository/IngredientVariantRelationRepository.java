package com.whipup.ingredient.repository;

import com.whipup.ingredient.domain.IngredientVariantRelation;
import com.whipup.ingredient.domain.IngredientVariantRelationId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientVariantRelationRepository
    extends JpaRepository<IngredientVariantRelation, IngredientVariantRelationId> {
}
