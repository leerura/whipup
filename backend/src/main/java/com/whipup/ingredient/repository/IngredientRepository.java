package com.whipup.ingredient.repository;

import com.whipup.ingredient.domain.Ingredient;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientRepository extends JpaRepository<Ingredient, Long> {

    List<Ingredient> findAllByOrderByCanonicalNameAsc();
}
