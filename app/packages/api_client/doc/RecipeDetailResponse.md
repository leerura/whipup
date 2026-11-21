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
**sourceTitle** | **String** | Title returned by the stored YouTube source metadata snapshot. | 
**sourceChannelName** | **String** |  | 
**sourceChannelId** | **String** |  | 
**sourceChannelThumbnailUrl** | **String** | Original YouTube channel profile image. Clients fall back to the channel name's first letter. | [optional] 
**sourceMetadataFetchedAt** | [**DateTime**](DateTime.md) | UTC time when the stored YouTube metadata snapshot was fetched. | 
**thumbnailUrl** | **String** |  | 
**missingCount** | **int** |  | 
**requirements** | [**BuiltList&lt;DetailRequirement&gt;**](DetailRequirement.md) |  | 
**optionalIngredients** | [**BuiltList&lt;DetailIngredientDisplay&gt;**](DetailIngredientDisplay.md) |  | 
**steps** | [**BuiltList&lt;RecipeStep&gt;**](RecipeStep.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


