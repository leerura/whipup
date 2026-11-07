# api_client.api.DailyMenuApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addDailyMenu**](DailyMenuApi.md#adddailymenu) | **POST** /api/v1/me/daily-menu | 
[**getDailyMenu**](DailyMenuApi.md#getdailymenu) | **GET** /api/v1/me/daily-menu | 
[**removeDailyMenu**](DailyMenuApi.md#removedailymenu) | **DELETE** /api/v1/me/daily-menu/{recipeId} | 


# **addDailyMenu**
> addDailyMenu(dailyMenuRequest)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getDailyMenuApi();
final DailyMenuRequest dailyMenuRequest = ; // DailyMenuRequest | 

try {
    api.addDailyMenu(dailyMenuRequest);
} on DioException catch (e) {
    print('Exception when calling DailyMenuApi->addDailyMenu: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dailyMenuRequest** | [**DailyMenuRequest**](DailyMenuRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDailyMenu**
> RecommendationListResponse getDailyMenu()



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getDailyMenuApi();

try {
    final response = api.getDailyMenu();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DailyMenuApi->getDailyMenu: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RecommendationListResponse**](RecommendationListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeDailyMenu**
> removeDailyMenu(recipeId)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getDailyMenuApi();
final int recipeId = 789; // int | 

try {
    api.removeDailyMenu(recipeId);
} on DioException catch (e) {
    print('Exception when calling DailyMenuApi->removeDailyMenu: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recipeId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

