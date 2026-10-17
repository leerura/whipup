package com.whipup.ingredient.repository;

import com.whipup.ingredient.domain.IngredientVariantRelation;
import com.whipup.ingredient.domain.IngredientVariantRelationId;
import java.util.Collection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientVariantRelationRepository
    extends JpaRepository<IngredientVariantRelation, IngredientVariantRelationId> {

    List<IngredientVariantRelation> findAllBySourceVariant_IdIn(
        Collection<Long> sourceVariantIds
    );
}
