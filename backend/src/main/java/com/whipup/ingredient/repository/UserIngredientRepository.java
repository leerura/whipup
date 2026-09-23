package com.whipup.ingredient.repository;

import com.whipup.ingredient.domain.UserIngredient;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserIngredientRepository extends JpaRepository<UserIngredient, Long> {

	boolean existsByUser_Id(Long userId);
}
