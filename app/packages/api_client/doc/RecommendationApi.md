# api_client.api.RecommendationApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getRecipeRecommendations**](RecommendationApi.md#getreciperecommendations) | **GET** /api/v1/recipes/recommendations | 


# **getRecipeRecommendations**
> RecommendationListResponse getRecipeRecommendations(mode)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getRecommendationApi();
final RecommendationMode mode = ; // RecommendationMode | 

try {
    final response = api.getRecipeRecommendations(mode);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RecommendationApi->getRecipeRecommendations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mode** | [**RecommendationMode**](.md)|  | 

### Return type

[**RecommendationListResponse**](RecommendationListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

