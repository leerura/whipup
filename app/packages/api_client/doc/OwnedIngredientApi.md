# api_client.api.OwnedIngredientApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addOwnedIngredients**](OwnedIngredientApi.md#addownedingredients) | **POST** /api/v1/me/ingredients | 
[**deleteOwnedIngredient**](OwnedIngredientApi.md#deleteownedingredient) | **DELETE** /api/v1/me/ingredients/{userIngredientId} | 
[**getOwnedIngredients**](OwnedIngredientApi.md#getownedingredients) | **GET** /api/v1/me/ingredients | 


# **addOwnedIngredients**
> OwnedIngredientListResponse addOwnedIngredients(addOwnedIngredientsRequest)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getOwnedIngredientApi();
final AddOwnedIngredientsRequest addOwnedIngredientsRequest = ; // AddOwnedIngredientsRequest | 

try {
    final response = api.addOwnedIngredients(addOwnedIngredientsRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OwnedIngredientApi->addOwnedIngredients: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addOwnedIngredientsRequest** | [**AddOwnedIngredientsRequest**](AddOwnedIngredientsRequest.md)|  | 

### Return type

[**OwnedIngredientListResponse**](OwnedIngredientListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteOwnedIngredient**
> deleteOwnedIngredient(userIngredientId)



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getOwnedIngredientApi();
final int userIngredientId = 789; // int | 

try {
    api.deleteOwnedIngredient(userIngredientId);
} on DioException catch (e) {
    print('Exception when calling OwnedIngredientApi->deleteOwnedIngredient: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userIngredientId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOwnedIngredients**
> OwnedIngredientListResponse getOwnedIngredients()



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getOwnedIngredientApi();

try {
    final response = api.getOwnedIngredients();
    print(response);
} on DioException catch (e) {
    print('Exception when calling OwnedIngredientApi->getOwnedIngredients: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**OwnedIngredientListResponse**](OwnedIngredientListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

