package com.whipup.ingredient.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.OffsetDateTime;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(
		name = "ingredient",
		uniqueConstraints = @UniqueConstraint(
				name = "uq_ingredient_canonical_name",
				columnNames = "canonical_name"
		)
)
public class Ingredient {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "ingredient_id")
	private Long id;

	@Column(name = "key", nullable = false, unique = true, length = 255)
	private String key;

	@Column(name = "canonical_name", nullable = false, length = 255)
	private String canonicalName;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private OffsetDateTime createdAt;

	@UpdateTimestamp
	@Column(name = "updated_at", nullable = false)
	private OffsetDateTime updatedAt;

    protected Ingredient() {
    }

    public static Ingredient create(String key, String canonicalName) {
        Ingredient ingredient = new Ingredient();
        ingredient.key = key;
        ingredient.canonicalName = canonicalName;
        return ingredient;
    }

    public static Ingredient create(String canonicalName) {
        return create(canonicalName, canonicalName);
    }

    public Long getId() {
        return id;
    }

    public String getCanonicalName() {
        return canonicalName;
    }

    public String getKey() {
        return key;
    }
}
