import 'package:test/test.dart';
import 'package:api_client/api_client.dart';

// tests for AppleLoginRequest
void main() {
  final instance = AppleLoginRequestBuilder();
  // TODO add properties to the builder and call build()

  group(AppleLoginRequest, () {
    // Apple identity token (JWT) returned to the app.
    // String identityToken
    test('to test the property `identityToken`', () async {
      // TODO
    });

    // Short-lived Apple authorization code the server exchanges with Apple.
    // String authorizationCode
    test('to test the property `authorizationCode`', () async {
      // TODO
    });

    // Raw nonce the app generated; its SHA-256 hex digest was sent to Apple.
    // String nonce
    test('to test the property `nonce`', () async {
      // TODO
    });

  });
}
