package com.whipup.ingredient.domain;

import com.whipup.user.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.OffsetDateTime;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(
		name = "user_ingredient",
		uniqueConstraints = @UniqueConstraint(
				name = "uq_user_ingredient_user_variant",
				columnNames = { "user_id", "ingredient_variant_id" }
		)
)
public class UserIngredient {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "user_ingredient_id")
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "ingredient_variant_id", nullable = false)
	private IngredientVariant ingredientVariant;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private OffsetDateTime createdAt;

	protected UserIngredient() {
	}

	private UserIngredient(User user, IngredientVariant ingredientVariant) {
		this.user = user;
		this.ingredientVariant = ingredientVariant;
	}

	public static UserIngredient create(User user, IngredientVariant ingredientVariant) {
		return new UserIngredient(user, ingredientVariant);
	}

	public static UserIngredient create(User user, Ingredient ingredient) {
		throw new UnsupportedOperationException(
			"UserIngredient must be created with an IngredientVariant"
		);
	}

	public Long getId() {
		return id;
	}

	public Ingredient getIngredient() {
		return ingredientVariant.getIngredient();
	}

	public IngredientVariant getIngredientVariant() {
		return ingredientVariant;
	}
}
