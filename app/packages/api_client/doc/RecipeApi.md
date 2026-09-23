# api_client.api.RecipeApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getRecipeDetail**](RecipeApi.md#getrecipedetail) | **GET** /recipes/{recipeId} | 


# **getRecipeDetail**
> RecipeDetailResponse getRecipeDetail(recipeId)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getRecipeApi();
final int recipeId = 789; // int | 

try {
    final response = api.getRecipeDetail(recipeId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RecipeApi->getRecipeDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recipeId** | **int**|  | 

### Return type

[**RecipeDetailResponse**](RecipeDetailResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

