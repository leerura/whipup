# api_client.api.OnboardingApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**completeOnboarding**](OnboardingApi.md#completeonboarding) | **POST** /api/v1/me/onboarding | 


# **completeOnboarding**
> completeOnboarding(onboardingRequest)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getOnboardingApi();
final OnboardingRequest onboardingRequest = ; // OnboardingRequest | 

try {
    api.completeOnboarding(onboardingRequest);
} on DioException catch (e) {
    print('Exception when calling OnboardingApi->completeOnboarding: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **onboardingRequest** | [**OnboardingRequest**](OnboardingRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

