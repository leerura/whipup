# api_client.api.IngredientApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getIngredientGroups**](IngredientApi.md#getingredientgroups) | **GET** /api/v1/ingredients | 


# **getIngredientGroups**
> IngredientGroupListResponse getIngredientGroups()



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getIngredientApi();

try {
    final response = api.getIngredientGroups();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IngredientApi->getIngredientGroups: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**IngredientGroupListResponse**](IngredientGroupListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

