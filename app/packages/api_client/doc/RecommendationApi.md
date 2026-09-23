# api_client.api.RecommendationApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getRecommendations**](RecommendationApi.md#getrecommendations) | **GET** /recommendations | 


# **getRecommendations**
> RecommendationPage getRecommendations(missingCount, page, size)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getRecommendationApi();
final int missingCount = 56; // int | 
final int page = 56; // int | 
final int size = 56; // int | 

try {
    final response = api.getRecommendations(missingCount, page, size);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RecommendationApi->getRecommendations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **missingCount** | **int**|  | 
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 30]

### Return type

[**RecommendationPage**](RecommendationPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

