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

import 'package:api_client/src/model/add_owned_ingredient_request.dart';
import 'package:api_client/src/model/detail_ingredient_display.dart';
import 'package:api_client/src/model/detail_requirement.dart';
import 'package:api_client/src/model/detail_requirement_option.dart';
import 'package:api_client/src/model/error_response.dart';
import 'package:api_client/src/model/health_response.dart';
import 'package:api_client/src/model/ingredient_group.dart';
import 'package:api_client/src/model/ingredient_group_list_response.dart';
import 'package:api_client/src/model/ingredient_match.dart';
import 'package:api_client/src/model/ingredient_variant_option.dart';
import 'package:api_client/src/model/kakao_login_request.dart';
import 'package:api_client/src/model/login_response.dart';
import 'package:api_client/src/model/missing_detail_requirement.dart';
import 'package:api_client/src/model/missing_option.dart';
import 'package:api_client/src/model/missing_requirement_result.dart';
import 'package:api_client/src/model/missing_substitute.dart';
import 'package:api_client/src/model/owned_ingredient.dart';
import 'package:api_client/src/model/owned_ingredient_list_response.dart';
import 'package:api_client/src/model/recipe_detail_response.dart';
import 'package:api_client/src/model/recipe_step.dart';
import 'package:api_client/src/model/recommendation_item.dart';
import 'package:api_client/src/model/recommendation_list_response.dart';
import 'package:api_client/src/model/recommendation_mode.dart';
import 'package:api_client/src/model/requirement_result.dart';
import 'package:api_client/src/model/satisfied_detail_requirement.dart';
import 'package:api_client/src/model/satisfied_requirement_result.dart';
import 'package:api_client/src/model/user_summary.dart';

part 'serializers.g.dart';

@SerializersFor([
  AddOwnedIngredientRequest,
  DetailIngredientDisplay,
  DetailRequirement,
  DetailRequirementOption,
  ErrorResponse,
  HealthResponse,
  IngredientGroup,
  IngredientGroupListResponse,
  IngredientMatch,
  IngredientVariantOption,
  KakaoLoginRequest,
  LoginResponse,
  MissingDetailRequirement,
  MissingOption,
  MissingRequirementResult,
  MissingSubstitute,
  OwnedIngredient,
  OwnedIngredientListResponse,
  RecipeDetailResponse,
  RecipeStep,
  RecommendationItem,
  RecommendationListResponse,
  RecommendationMode,
  RequirementResult,
  SatisfiedDetailRequirement,
  SatisfiedRequirementResult,
  UserSummary,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RequirementResult)]),
        () => ListBuilder<RequirementResult>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MissingSubstitute)]),
        () => ListBuilder<MissingSubstitute>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MissingOption)]),
        () => ListBuilder<MissingOption>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DetailRequirement)]),
        () => ListBuilder<DetailRequirement>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DetailRequirementOption)]),
        () => ListBuilder<DetailRequirementOption>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(IngredientMatch)]),
        () => ListBuilder<IngredientMatch>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DetailIngredientDisplay)]),
        () => ListBuilder<DetailIngredientDisplay>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(IngredientVariantOption)]),
        () => ListBuilder<IngredientVariantOption>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(OwnedIngredient)]),
        () => ListBuilder<OwnedIngredient>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RecipeStep)]),
        () => ListBuilder<RecipeStep>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(IngredientGroup)]),
        () => ListBuilder<IngredientGroup>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RecommendationItem)]),
        () => ListBuilder<RecommendationItem>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
