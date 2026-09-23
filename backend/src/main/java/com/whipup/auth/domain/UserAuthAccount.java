package com.whipup.auth.domain;

import com.whipup.user.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(
		name = "user_auth_account",
		uniqueConstraints = @UniqueConstraint(
				name = "uq_user_auth_account_provider_user",
				columnNames = { "provider", "provider_user_id" }
		)
)
public class UserAuthAccount {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "auth_account_id")
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@Enumerated(EnumType.STRING)
	@Column(name = "provider", nullable = false, length = 50)
	private AuthProvider provider;

	@Column(name = "provider_user_id", nullable = false, length = 255)
	private String providerUserId;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private OffsetDateTime createdAt;

	@UpdateTimestamp
	@Column(name = "updated_at", nullable = false)
	private OffsetDateTime updatedAt;

	protected UserAuthAccount() {
	}

	public static UserAuthAccount link(User user, AuthProvider provider, String providerUserId) {
		UserAuthAccount account = new UserAuthAccount();
		account.user = user;
		account.provider = provider;
		account.providerUserId = providerUserId;
		return account;
	}

	public User getUser() {
		return user;
	}
}
