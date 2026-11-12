package com.whipup.auth.apple;

import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.stereotype.Component;

/** AES-256-GCM encryption for the stored Apple refresh token. */
@Component
public class AppleTokenCipher {

	private static final int IV_BYTES = 12;
	private static final int TAG_BITS = 128;

	private final AppleProperties properties;
	private final SecureRandom random = new SecureRandom();

	public AppleTokenCipher(AppleProperties properties) {
		this.properties = properties;
	}

	public String encrypt(String plainText) {
		try {
			byte[] iv = new byte[IV_BYTES];
			random.nextBytes(iv);
			Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
			cipher.init(Cipher.ENCRYPT_MODE, key(), new GCMParameterSpec(TAG_BITS, iv));
			byte[] encrypted = cipher.doFinal(plainText.getBytes(java.nio.charset.StandardCharsets.UTF_8));
			return Base64.getEncoder().encodeToString(
					ByteBuffer.allocate(iv.length + encrypted.length).put(iv).put(encrypted).array()
			);
		} catch (GeneralSecurityException exception) {
			throw new AppleLoginUnavailableException("Apple token encryption failed", exception);
		}
	}

	public String decrypt(String encoded) {
		try {
			ByteBuffer buffer = ByteBuffer.wrap(Base64.getDecoder().decode(encoded));
			byte[] iv = new byte[IV_BYTES];
			buffer.get(iv);
			byte[] encrypted = new byte[buffer.remaining()];
			buffer.get(encrypted);
			Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
			cipher.init(Cipher.DECRYPT_MODE, key(), new GCMParameterSpec(TAG_BITS, iv));
			return new String(cipher.doFinal(encrypted), java.nio.charset.StandardCharsets.UTF_8);
		} catch (GeneralSecurityException | RuntimeException exception) {
			throw new AppleLoginUnavailableException("Apple token decryption failed", exception);
		}
	}

	private SecretKeySpec key() {
		String encoded = properties.tokenEncryptionKey();
		if (encoded == null || encoded.isBlank()) {
			throw new AppleLoginUnavailableException("Apple token encryption key is not configured");
		}
		byte[] key = Base64.getDecoder().decode(encoded.trim());
		if (key.length != 32) {
			throw new AppleLoginUnavailableException("Apple token encryption key must be 32 bytes");
		}
		return new SecretKeySpec(key, "AES");
	}
}
