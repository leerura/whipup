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
[**getCurrentAccount**](AuthApi.md#getcurrentaccount) | **GET** /api/v1/me | Read the authenticated account state
[**startGuestSession**](AuthApi.md#startguestsession) | **POST** /api/v1/auth/guest | Create a guest account without personal information


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

Permanently deletes the current user, linked provider accounts, owned ingredients, and onboarding state in one transaction. No backup is retained. Shared ingredient/catalog and recipe data are not deleted. Logout does not exist; after deletion the app starts a new guest account.

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

# **getCurrentAccount**
> CurrentAccountResponse getCurrentAccount()

Read the authenticated account state

Returns the same account state fields as LoginResponse without issuing a token. Callable while terms consent is still pending.

### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getAuthApi();

try {
    final response = api.getCurrentAccount();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->getCurrentAccount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CurrentAccountResponse**](CurrentAccountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startGuestSession**
> LoginResponse startGuestSession()

Create a guest account without personal information

Creates a new account with no personal information and returns the same LoginResponse shape as before. The account always starts with terms consent required and onboarding incomplete.

### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getAuthApi();

try {
    final response = api.startGuestSession();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->startGuestSession: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**LoginResponse**](LoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

