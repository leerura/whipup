package com.whipup.recipe.repository;

import com.whipup.recipe.domain.Recipe;
import com.whipup.recipe.domain.RecipeStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    Optional<Recipe> findByDatasetKey(String datasetKey);

    Optional<Recipe> findByIdAndStatus(Long recipeId, RecipeStatus status);

    List<Recipe> findAllByStatusOrderByIdAsc(RecipeStatus status);

    @Modifying
    @Query("delete from Recipe recipe where recipe.datasetKey in :datasetKeys")
    void deleteAllByDatasetKeyIn(@Param("datasetKeys") Set<String> datasetKeys);
}
