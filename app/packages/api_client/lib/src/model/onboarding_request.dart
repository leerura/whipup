//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'onboarding_request.g.dart';

/// OnboardingRequest
///
/// Properties:
/// * [variantIds] 
@BuiltValue()
abstract class OnboardingRequest implements Built<OnboardingRequest, OnboardingRequestBuilder> {
  @BuiltValueField(wireName: r'variantIds')
  BuiltSet<int> get variantIds;

  OnboardingRequest._();

  factory OnboardingRequest([void updates(OnboardingRequestBuilder b)]) = _$OnboardingRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OnboardingRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OnboardingRequest> get serializer => _$OnboardingRequestSerializer();
}

class _$OnboardingRequestSerializer implements PrimitiveSerializer<OnboardingRequest> {
  @override
  final Iterable<Type> types = const [OnboardingRequest, _$OnboardingRequest];

  @override
  final String wireName = r'OnboardingRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OnboardingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variantIds';
    yield serializers.serialize(
      object.variantIds,
      specifiedType: const FullType(BuiltSet, [FullType(int)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OnboardingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OnboardingRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(int)]),
          ) as BuiltSet<int>;
          result.variantIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OnboardingRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OnboardingRequestBuilder();
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


