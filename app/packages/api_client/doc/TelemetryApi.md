# api_client.api.TelemetryApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**recordHttpTiming**](TelemetryApi.md#recordhttptiming) | **POST** /api/v1/telemetry/http-timing | 


# **recordHttpTiming**
> recordHttpTiming(httpTimingRequest)



Aggregates authenticated client HTTP timing without storing raw events.

### Example
```dart
import 'package:api_client/api.dart';

final api = ApiClient().getTelemetryApi();
final HttpTimingRequest httpTimingRequest = ; // HttpTimingRequest | 

try {
    api.recordHttpTiming(httpTimingRequest);
} on DioException catch (e) {
    print('Exception when calling TelemetryApi->recordHttpTiming: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **httpTimingRequest** | [**HttpTimingRequest**](HttpTimingRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

