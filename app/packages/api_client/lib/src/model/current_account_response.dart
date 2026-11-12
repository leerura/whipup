//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:api_client/src/model/user_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'current_account_response.g.dart';

/// CurrentAccountResponse
///
/// Properties:
/// * [user] 
/// * [hasOwnedIngredients] 
/// * [onboardingCompleted] 
/// * [termsConsentRequired] 
@BuiltValue()
abstract class CurrentAccountResponse implements Built<CurrentAccountResponse, CurrentAccountResponseBuilder> {
  @BuiltValueField(wireName: r'user')
  UserSummary get user;

  @BuiltValueField(wireName: r'hasOwnedIngredients')
  bool get hasOwnedIngredients;

  @BuiltValueField(wireName: r'onboardingCompleted')
  bool get onboardingCompleted;

  @BuiltValueField(wireName: r'termsConsentRequired')
  bool get termsConsentRequired;

  CurrentAccountResponse._();

  factory CurrentAccountResponse([void updates(CurrentAccountResponseBuilder b)]) = _$CurrentAccountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CurrentAccountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CurrentAccountResponse> get serializer => _$CurrentAccountResponseSerializer();
}

class _$CurrentAccountResponseSerializer implements PrimitiveSerializer<CurrentAccountResponse> {
  @override
  final Iterable<Type> types = const [CurrentAccountResponse, _$CurrentAccountResponse];

  @override
  final String wireName = r'CurrentAccountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CurrentAccountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserSummary),
    );
    yield r'hasOwnedIngredients';
    yield serializers.serialize(
      object.hasOwnedIngredients,
      specifiedType: const FullType(bool),
    );
    yield r'onboardingCompleted';
    yield serializers.serialize(
      object.onboardingCompleted,
      specifiedType: const FullType(bool),
    );
    yield r'termsConsentRequired';
    yield serializers.serialize(
      object.termsConsentRequired,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CurrentAccountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CurrentAccountResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserSummary),
          ) as UserSummary;
          result.user.replace(valueDes);
          break;
        case r'hasOwnedIngredients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasOwnedIngredients = valueDes;
          break;
        case r'onboardingCompleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.onboardingCompleted = valueDes;
          break;
        case r'termsConsentRequired':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.termsConsentRequired = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CurrentAccountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CurrentAccountResponseBuilder();
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


