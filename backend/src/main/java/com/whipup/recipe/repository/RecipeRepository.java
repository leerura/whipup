package com.whipup.recipe.repository;

import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    Optional<Recipe> findByDatasetKey(String datasetKey);

    Optional<Recipe> findByIdAndStatus(Long recipeId, RecipeStatus status);

    List<Recipe> findAllByStatusOrderByIdAsc(RecipeStatus status);
}
