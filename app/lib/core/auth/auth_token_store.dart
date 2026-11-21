import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the WhipUp access token in the platform secure storage (iOS Keychain)
/// so the user stays signed in until the token expires.
///
/// Storage failures never break login: reads return null and writes/deletes
/// are skipped, which only means the user signs in again next time.
class AuthTokenStore {
  AuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'whipup_access_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      final token = await _storage.read(key: _key);
      return (token == null || token.isEmpty) ? null : token;
    } catch (error) {
      debugPrint('[Auth token] read failed: $error');
      return null;
    }
  }

  Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (error) {
      debugPrint('[Auth token] write failed: $error');
    }
  }

  Future<void> delete() async {
    try {
      await _storage.delete(key: _key);
    } catch (error) {
      debugPrint('[Auth token] delete failed: $error');
    }
  }
}
