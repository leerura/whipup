# api_client.model.RecommendationItem

## Load the model package
```dart
import 'package:api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**recipeId** | **int** |  | 
**name** | **String** |  | 
**thumbnailUrl** | **String** |  | 
**missingCount** | **int** |  | 
**requirementResults** | [**BuiltList&lt;RequirementResult&gt;**](RequirementResult.md) |  | 
**sourceChannelName** | **String** | Original YouTube channel name, used to tell apart recipes with the same name. | [optional] 
**sourceChannelThumbnailUrl** | **String** | Original YouTube channel profile image. Clients fall back to the channel name's first letter. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


