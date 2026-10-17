package com.whipup.ingredient.repository;

import com.whipup.ingredient.domain.IngredientVariant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientVariantRepository extends JpaRepository<IngredientVariant, Long> {

    Optional<IngredientVariant> findByKey(String key);

    List<IngredientVariant> findAllByIngredient_IdOrderByNameAsc(Long ingredientId);
}
