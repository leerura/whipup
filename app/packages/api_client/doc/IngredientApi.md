# api_client.api.IngredientApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getIngredientOptions**](IngredientApi.md#getingredientoptions) | **GET** /api/v1/ingredients | 


# **getIngredientOptions**
> IngredientOptionListResponse getIngredientOptions()



### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getIngredientApi();

try {
    final response = api.getIngredientOptions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IngredientApi->getIngredientOptions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**IngredientOptionListResponse**](IngredientOptionListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

