package com.whipup.ingredient.repository;

import com.whipup.ingredient.domain.UserIngredient;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserIngredientRepository extends JpaRepository<UserIngredient, Long> {

	boolean existsByUser_Id(Long userId);

	boolean existsByUser_IdAndIngredientVariant_IdIn(
			Long userId,
			Collection<Long> variantIds
	);

	boolean existsByIngredientVariant_IdIn(Collection<Long> variantIds);

	List<UserIngredient> findAllByUser_IdOrderByIngredientVariant_NameAsc(
			Long userId
	);

	Optional<UserIngredient> findByIdAndUser_Id(
			Long id,
			Long userId
	);
}
