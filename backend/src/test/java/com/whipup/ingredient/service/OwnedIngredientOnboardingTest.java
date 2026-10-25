package com.whipup.ingredient.service;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.whipup.ingredient.domain.IngredientVariant;
import com.whipup.ingredient.domain.UserIngredient;
import com.whipup.ingredient.repository.IngredientVariantRepository;
import com.whipup.ingredient.repository.UserIngredientRepository;
import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class OwnedIngredientOnboardingTest {

    private final IngredientVariantRepository ingredientVariantRepository = mock(IngredientVariantRepository.class);
    private final UserIngredientRepository userIngredientRepository = mock(UserIngredientRepository.class);
    private final UserRepository userRepository = mock(UserRepository.class);

    @Test
    void successfulFirstIngredientRegistrationMarksOnboardingComplete() {
        User user = User.create();
        assertFalse(user.isOnboardingCompleted());
        IngredientVariant variant = mock(IngredientVariant.class);
        when(variant.getId()).thenReturn(5L);
        when(variant.getName()).thenReturn("계란");
        when(ingredientVariantRepository.findById(5L)).thenReturn(Optional.of(variant));
        when(userIngredientRepository.existsByUser_IdAndIngredientVariant_IdIn(7L, java.util.List.of(5L)))
            .thenReturn(false);
        when(userRepository.getReferenceById(7L)).thenReturn(user);
        UserIngredient saved = savedIngredient(11L, variant);
        when(userIngredientRepository.saveAndFlush(any(UserIngredient.class)))
            .thenReturn(saved);

        new OwnedIngredientService(
            ingredientVariantRepository,
            userIngredientRepository,
            userRepository
        ).addOwnedIngredient(7L, 5L);

        assertTrue(user.isOnboardingCompleted());
    }

    @Test
    void deletingOwnedIngredientsDoesNotResetOnboardingCompletion() {
        User user = User.create();
        user.markOnboardingCompleted();
        UserIngredient owned = mock(UserIngredient.class);
        when(userIngredientRepository.findByIdAndUser_Id(11L, 7L))
            .thenReturn(Optional.of(owned));

        new OwnedIngredientService(
            ingredientVariantRepository,
            userIngredientRepository,
            userRepository
        ).deleteOwnedIngredient(7L, 11L);

        verify(userIngredientRepository).delete(owned);
        assertTrue(user.isOnboardingCompleted());
    }

    private UserIngredient savedIngredient(Long id, IngredientVariant variant) {
        UserIngredient saved = mock(UserIngredient.class);
        when(saved.getId()).thenReturn(id);
        when(saved.getIngredientVariant()).thenReturn(variant);
        return saved;
    }
}
