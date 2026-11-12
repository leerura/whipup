# api_client.model.AppleLoginRequest

## Load the model package
```dart
import 'package:api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**identityToken** | **String** | Apple identity token (JWT) returned to the app. | 
**authorizationCode** | **String** | Short-lived Apple authorization code the server exchanges with Apple. | 
**nonce** | **String** | Raw nonce the app generated; its SHA-256 hex digest was sent to Apple. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


