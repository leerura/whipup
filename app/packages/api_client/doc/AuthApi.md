# api_client.api.AuthApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**loginWithKakao**](AuthApi.md#loginwithkakao) | **POST** /api/v1/auth/kakao | 
[**deleteCurrentAccount**](AuthApi.md#deletecurrentaccount) | **DELETE** /api/v1/me | Permanently delete the authenticated account

# **deleteCurrentAccount**
> deleteCurrentAccount()

Permanently deletes the current account and user-owned data. Shared catalog and recipe data are preserved.

### Authorization

Bearer authentication required.


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

