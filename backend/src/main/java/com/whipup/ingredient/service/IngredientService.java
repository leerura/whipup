package com.whipup.ingredient.service;

import com.whipup.generated.model.IngredientGroup;
import com.whipup.generated.model.IngredientGroupListResponse;
import com.whipup.generated.model.IngredientVariantOption;
import com.whipup.ingredient.domain.Ingredient;
import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.repository.IngredientRepository;
import com.whipup.ingredient.repository.IngredientVariantRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class IngredientService {

    private final IngredientRepository ingredientRepository;
    private final IngredientVariantRepository variantRepository;

    public IngredientService(
        IngredientRepository ingredientRepository,
        IngredientVariantRepository variantRepository
    ) {
        this.ingredientRepository = ingredientRepository;
        this.variantRepository = variantRepository;
    }

    @Transactional(readOnly = true)
    public IngredientGroupListResponse getIngredientGroups() {
        List<IngredientGroup> groups = ingredientRepository.findAllByOrderByCanonicalNameAsc().stream()
            .map(this::toGroup)
            .toList();

        return new IngredientGroupListResponse(groups);
    }

    private IngredientGroup toGroup(Ingredient ingredient) {
        List<IngredientVariantOption> items = variantRepository
            .findAllByIngredient_IdOrderByNameAsc(ingredient.getId())
            .stream()
            .map(this::toOption)
            .toList();
        return new IngredientGroup(ingredient.getCanonicalName(), items);
    }

    private IngredientVariantOption toOption(IngredientVariant variant) {
        return new IngredientVariantOption(variant.getId(), variant.getName());
    }
}
