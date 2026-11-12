//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'http_timing_request.g.dart';

/// HttpTimingRequest
///
/// Properties:
/// * [route] 
/// * [method] 
/// * [outcome] 
/// * [durationMs] 
@BuiltValue()
abstract class HttpTimingRequest implements Built<HttpTimingRequest, HttpTimingRequestBuilder> {
  @BuiltValueField(wireName: r'route')
  HttpTimingRequestRouteEnum get route;
  // enum routeEnum {  /api/v1/auth/kakao,  /api/v1/auth/apple,  /api/v1/me,  /api/v1/me/terms-consent,  /api/v1/me/onboarding,  /api/v1/recipes/recommendations,  /api/v1/recipes/search,  /api/v1/recipes/{recipeId},  /api/v1/me/daily-menu,  /api/v1/me/daily-menu/{recipeId},  /api/v1/me/ingredients,  /api/v1/me/ingredients/{userIngredientId},  /api/v1/ingredients,  };

  @BuiltValueField(wireName: r'method')
  HttpTimingRequestMethodEnum get method;
  // enum methodEnum {  GET,  POST,  DELETE,  };

  @BuiltValueField(wireName: r'outcome')
  HttpTimingRequestOutcomeEnum get outcome;
  // enum outcomeEnum {  SUCCESS,  CLIENT_ERROR,  SERVER_ERROR,  NETWORK_ERROR,  };

  @BuiltValueField(wireName: r'durationMs')
  int get durationMs;

  HttpTimingRequest._();

  factory HttpTimingRequest([void updates(HttpTimingRequestBuilder b)]) = _$HttpTimingRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HttpTimingRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HttpTimingRequest> get serializer => _$HttpTimingRequestSerializer();
}

class _$HttpTimingRequestSerializer implements PrimitiveSerializer<HttpTimingRequest> {
  @override
  final Iterable<Type> types = const [HttpTimingRequest, _$HttpTimingRequest];

  @override
  final String wireName = r'HttpTimingRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HttpTimingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'route';
    yield serializers.serialize(
      object.route,
      specifiedType: const FullType(HttpTimingRequestRouteEnum),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(HttpTimingRequestMethodEnum),
    );
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(HttpTimingRequestOutcomeEnum),
    );
    yield r'durationMs';
    yield serializers.serialize(
      object.durationMs,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HttpTimingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HttpTimingRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'route':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HttpTimingRequestRouteEnum),
          ) as HttpTimingRequestRouteEnum;
          result.route = valueDes;
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HttpTimingRequestMethodEnum),
          ) as HttpTimingRequestMethodEnum;
          result.method = valueDes;
          break;
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HttpTimingRequestOutcomeEnum),
          ) as HttpTimingRequestOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'durationMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HttpTimingRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HttpTimingRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


class HttpTimingRequestRouteEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'/api/v1/auth/kakao')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashAuthSlashKakao = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashAuthSlashKakao;
  @BuiltValueEnumConst(wireName: r'/api/v1/auth/apple')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashAuthSlashApple = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashAuthSlashApple;
  @BuiltValueEnumConst(wireName: r'/api/v1/me')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMe = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMe;
  @BuiltValueEnumConst(wireName: r'/api/v1/me/terms-consent')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMeSlashTermsConsent = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMeSlashTermsConsent;
  @BuiltValueEnumConst(wireName: r'/api/v1/me/onboarding')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMeSlashOnboarding = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMeSlashOnboarding;
  @BuiltValueEnumConst(wireName: r'/api/v1/recipes/recommendations')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashRecipesSlashRecommendations = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashRecipesSlashRecommendations;
  @BuiltValueEnumConst(wireName: r'/api/v1/recipes/search')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashRecipesSlashSearch = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashRecipesSlashSearch;
  @BuiltValueEnumConst(wireName: r'/api/v1/recipes/{recipeId}')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashRecipesSlashLeftCurlyBracketRecipeIdRightCurlyBracket = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashRecipesSlashLeftCurlyBracketRecipeIdRightCurlyBracket;
  @BuiltValueEnumConst(wireName: r'/api/v1/me/daily-menu')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMeSlashDailyMenu = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMeSlashDailyMenu;
  @BuiltValueEnumConst(wireName: r'/api/v1/me/daily-menu/{recipeId}')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMeSlashDailyMenuSlashLeftCurlyBracketRecipeIdRightCurlyBracket = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMeSlashDailyMenuSlashLeftCurlyBracketRecipeIdRightCurlyBracket;
  @BuiltValueEnumConst(wireName: r'/api/v1/me/ingredients')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMeSlashIngredients = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMeSlashIngredients;
  @BuiltValueEnumConst(wireName: r'/api/v1/me/ingredients/{userIngredientId}')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashMeSlashIngredientsSlashLeftCurlyBracketUserIngredientIdRightCurlyBracket = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashMeSlashIngredientsSlashLeftCurlyBracketUserIngredientIdRightCurlyBracket;
  @BuiltValueEnumConst(wireName: r'/api/v1/ingredients')
  static const HttpTimingRequestRouteEnum slashApiSlashV1SlashIngredients = _$httpTimingRequestRouteEnum_slashApiSlashV1SlashIngredients;

  static Serializer<HttpTimingRequestRouteEnum> get serializer => _$httpTimingRequestRouteEnumSerializer;

  const HttpTimingRequestRouteEnum._(String name): super(name);

  static BuiltSet<HttpTimingRequestRouteEnum> get values => _$httpTimingRequestRouteEnumValues;
  static HttpTimingRequestRouteEnum valueOf(String name) => _$httpTimingRequestRouteEnumValueOf(name);
}

class HttpTimingRequestMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GET')
  static const HttpTimingRequestMethodEnum GET = _$httpTimingRequestMethodEnum_GET;
  @BuiltValueEnumConst(wireName: r'POST')
  static const HttpTimingRequestMethodEnum POST = _$httpTimingRequestMethodEnum_POST;
  @BuiltValueEnumConst(wireName: r'DELETE')
  static const HttpTimingRequestMethodEnum DELETE = _$httpTimingRequestMethodEnum_DELETE;

  static Serializer<HttpTimingRequestMethodEnum> get serializer => _$httpTimingRequestMethodEnumSerializer;

  const HttpTimingRequestMethodEnum._(String name): super(name);

  static BuiltSet<HttpTimingRequestMethodEnum> get values => _$httpTimingRequestMethodEnumValues;
  static HttpTimingRequestMethodEnum valueOf(String name) => _$httpTimingRequestMethodEnumValueOf(name);
}

class HttpTimingRequestOutcomeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SUCCESS')
  static const HttpTimingRequestOutcomeEnum SUCCESS = _$httpTimingRequestOutcomeEnum_SUCCESS;
  @BuiltValueEnumConst(wireName: r'CLIENT_ERROR')
  static const HttpTimingRequestOutcomeEnum CLIENT_ERROR = _$httpTimingRequestOutcomeEnum_CLIENT_ERROR;
  @BuiltValueEnumConst(wireName: r'SERVER_ERROR')
  static const HttpTimingRequestOutcomeEnum SERVER_ERROR = _$httpTimingRequestOutcomeEnum_SERVER_ERROR;
  @BuiltValueEnumConst(wireName: r'NETWORK_ERROR')
  static const HttpTimingRequestOutcomeEnum NETWORK_ERROR = _$httpTimingRequestOutcomeEnum_NETWORK_ERROR;

  static Serializer<HttpTimingRequestOutcomeEnum> get serializer => _$httpTimingRequestOutcomeEnumSerializer;

  const HttpTimingRequestOutcomeEnum._(String name): super(name);

  static BuiltSet<HttpTimingRequestOutcomeEnum> get values => _$httpTimingRequestOutcomeEnumValues;
  static HttpTimingRequestOutcomeEnum valueOf(String name) => _$httpTimingRequestOutcomeEnumValueOf(name);
}

