# api_client.api.AuthApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptTermsConsent**](AuthApi.md#accepttermsconsent) | **POST** /api/v1/me/terms-consent | 
[**deleteCurrentAccount**](AuthApi.md#deletecurrentaccount) | **DELETE** /api/v1/me | Permanently delete the authenticated account
[**loginWithKakao**](AuthApi.md#loginwithkakao) | **POST** /api/v1/auth/kakao | 


# **acceptTermsConsent**
> acceptTermsConsent(termsConsentRequest)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getAuthApi();
final TermsConsentRequest termsConsentRequest = ; // TermsConsentRequest | 

try {
    api.acceptTermsConsent(termsConsentRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->acceptTermsConsent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **termsConsentRequest** | [**TermsConsentRequest**](TermsConsentRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCurrentAccount**
> deleteCurrentAccount()

Permanently delete the authenticated account

Permanently deletes the current user, linked provider accounts, owned ingredients, and onboarding state in one transaction. No backup is retained. Shared ingredient/catalog and recipe data are not deleted. Logout is client-side and has no backend endpoint.

### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getAuthApi();

try {
    api.deleteCurrentAccount();
} on DioException catch (e) {
    print('Exception when calling AuthApi->deleteCurrentAccount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginWithKakao**
> LoginResponse loginWithKakao(kakaoLoginRequest)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getAuthApi();
final KakaoLoginRequest kakaoLoginRequest = ; // KakaoLoginRequest | 

try {
    final response = api.loginWithKakao(kakaoLoginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->loginWithKakao: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **kakaoLoginRequest** | [**KakaoLoginRequest**](KakaoLoginRequest.md)|  | 

### Return type

[**LoginResponse**](LoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

