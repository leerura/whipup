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
				name = "uq_user_ingredient_user_ingredient",
				columnNames = { "user_id", "ingredient_id" }
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
	@JoinColumn(name = "ingredient_id", nullable = false)
	private Ingredient ingredient;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private OffsetDateTime createdAt;

	protected UserIngredient() {
	}

	private UserIngredient(User user, Ingredient ingredient) {
		this.user = user;
		this.ingredient = ingredient;
	}

	public static UserIngredient create(User user, Ingredient ingredient) {
		return new UserIngredient(user, ingredient);
	}

	public Long getId() {
		return id;
	}

	public Ingredient getIngredient() {
		return ingredient;
	}
}
