package com.whipup.user.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "users")
public class User {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "user_id")
	private Long id;

	@CreationTimestamp
	@Column(name = "created_at", nullable = false, updatable = false)
	private OffsetDateTime createdAt;

	@UpdateTimestamp
	@Column(name = "updated_at", nullable = false)
	private OffsetDateTime updatedAt;

	@Column(name = "onboarding_completed", nullable = false)
	private boolean onboardingCompleted;

	@Column(name = "terms_version")
	private String termsVersion;

	@Column(name = "terms_accepted_at")
	private OffsetDateTime termsAcceptedAt;

	@Column(name = "privacy_version")
	private String privacyVersion;

	@Column(name = "privacy_accepted_at")
	private OffsetDateTime privacyAcceptedAt;

	@Column(name = "age_14_confirmed_at")
	private OffsetDateTime age14ConfirmedAt;

	@Column(name = "last_active_at", nullable = false)
	private OffsetDateTime lastActiveAt;

	protected User() {
	}

	public static User create() {
		User user = new User();
		user.lastActiveAt = OffsetDateTime.now();
		return user;
	}

	/** Records that the account was just used, so it is not deleted as inactive. */
	public void markActive(OffsetDateTime now) {
		this.lastActiveAt = now;
	}

	public OffsetDateTime getLastActiveAt() {
		return lastActiveAt;
	}

	public Long getId() {
		return id;
	}

	public boolean isOnboardingCompleted() {
		return onboardingCompleted;
	}

	public void markOnboardingCompleted() {
		this.onboardingCompleted = true;
	}

	public boolean requiresTermsConsent(String currentTermsVersion, String currentPrivacyVersion) {
		return termsAcceptedAt == null
				|| privacyAcceptedAt == null
				|| age14ConfirmedAt == null
				|| !currentTermsVersion.equals(termsVersion)
				|| !currentPrivacyVersion.equals(privacyVersion);
	}

	public void acceptTerms(
			String termsVersion,
			String privacyVersion,
			OffsetDateTime acceptedAt
	) {
		this.termsVersion = termsVersion;
		this.termsAcceptedAt = acceptedAt;
		this.privacyVersion = privacyVersion;
		this.privacyAcceptedAt = acceptedAt;
		this.age14ConfirmedAt = acceptedAt;
	}
}
