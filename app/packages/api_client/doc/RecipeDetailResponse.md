# api_client.model.RecipeDetailResponse

## Load the model package
```dart
import 'package:api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**recipeId** | **int** |  | 
**name** | **String** |  | 
**shortsReference** | **String** |  | 
**sourceTitle** | **String** | Source video title | [optional]
**sourceChannelName** | **String** | Source channel name | [optional]
**sourceChannelId** | **String** | Source channel identifier | [optional]
**sourceMetadataFetchedAt** | **DateTime** | Source metadata snapshot time | [optional]
**thumbnailUrl** | **String** |  | 
**missingCount** | **int** |  | 
**requirements** | [**BuiltList&lt;DetailRequirement&gt;**](DetailRequirement.md) |  | 
**optionalIngredients** | [**BuiltList&lt;DetailIngredientDisplay&gt;**](DetailIngredientDisplay.md) |  | 
**steps** | [**BuiltList&lt;RecipeStep&gt;**](RecipeStep.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


