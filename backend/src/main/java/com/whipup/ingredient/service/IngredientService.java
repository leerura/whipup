package com.whipup.ingredient.service;

import com.whipup.generated.model.IngredientOption;
import com.whipup.generated.model.IngredientOptionListResponse;
import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.repository.IngredientRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class IngredientService {

    private final IngredientRepository ingredientRepository;

    public IngredientService(IngredientRepository ingredientRepository) {
        this.ingredientRepository = ingredientRepository;
    }

    @Transactional(readOnly = true)
    public IngredientOptionListResponse getIngredientOptions() {
        List<IngredientOption> items =
                ingredientRepository.findAllByOrderByCanonicalNameAsc().stream()
                        .map(this::toIngredientOption)
                        .toList();

        return new IngredientOptionListResponse(items);
    }

    private IngredientOption toIngredientOption(Ingredient ingredient) {
        return new IngredientOption(
                ingredient.getId(),
                ingredient.getCanonicalName());
    }
}
