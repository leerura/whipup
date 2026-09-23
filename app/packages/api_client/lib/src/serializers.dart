//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:api_client/src/date_serializer.dart';
import 'package:api_client/src/model/date.dart';

import 'package:api_client/src/model/add_owned_ingredients_request.dart';
import 'package:api_client/src/model/error_response.dart';
import 'package:api_client/src/model/health_response.dart';
import 'package:api_client/src/model/ingredient_option.dart';
import 'package:api_client/src/model/ingredient_option_list_response.dart';
import 'package:api_client/src/model/kakao_login_request.dart';
import 'package:api_client/src/model/login_response.dart';
import 'package:api_client/src/model/missing_ingredient.dart';
import 'package:api_client/src/model/owned_ingredient.dart';
import 'package:api_client/src/model/owned_ingredient_list_response.dart';
import 'package:api_client/src/model/owned_ingredient_selection.dart';
import 'package:api_client/src/model/recipe_detail_response.dart';
import 'package:api_client/src/model/recipe_ingredient.dart';
import 'package:api_client/src/model/recipe_step.dart';
import 'package:api_client/src/model/recommendation_item.dart';
import 'package:api_client/src/model/recommendation_page.dart';
import 'package:api_client/src/model/user_summary.dart';

part 'serializers.g.dart';

@SerializersFor([
  AddOwnedIngredientsRequest,
  ErrorResponse,
  HealthResponse,
  IngredientOption,
  IngredientOptionListResponse,
  KakaoLoginRequest,
  LoginResponse,
  MissingIngredient,
  OwnedIngredient,
  OwnedIngredientListResponse,
  OwnedIngredientSelection,
  RecipeDetailResponse,
  RecipeIngredient,
  RecipeStep,
  RecommendationItem,
  RecommendationPage,
  UserSummary,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
