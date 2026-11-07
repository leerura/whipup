//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'terms_consent_request.g.dart';

/// TermsConsentRequest
///
/// Properties:
/// * [termsVersion] 
/// * [privacyVersion] 
/// * [age14OrOver] 
@BuiltValue()
abstract class TermsConsentRequest implements Built<TermsConsentRequest, TermsConsentRequestBuilder> {
  @BuiltValueField(wireName: r'termsVersion')
  String get termsVersion;

  @BuiltValueField(wireName: r'privacyVersion')
  String get privacyVersion;

  @BuiltValueField(wireName: r'age14OrOver')
  bool get age14OrOver;

  TermsConsentRequest._();

  factory TermsConsentRequest([void updates(TermsConsentRequestBuilder b)]) = _$TermsConsentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TermsConsentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TermsConsentRequest> get serializer => _$TermsConsentRequestSerializer();
}

class _$TermsConsentRequestSerializer implements PrimitiveSerializer<TermsConsentRequest> {
  @override
  final Iterable<Type> types = const [TermsConsentRequest, _$TermsConsentRequest];

  @override
  final String wireName = r'TermsConsentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TermsConsentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'termsVersion';
    yield serializers.serialize(
      object.termsVersion,
      specifiedType: const FullType(String),
    );
    yield r'privacyVersion';
    yield serializers.serialize(
      object.privacyVersion,
      specifiedType: const FullType(String),
    );
    yield r'age14OrOver';
    yield serializers.serialize(
      object.age14OrOver,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TermsConsentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TermsConsentRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'termsVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.termsVersion = valueDes;
          break;
        case r'privacyVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.privacyVersion = valueDes;
          break;
        case r'age14OrOver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.age14OrOver = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TermsConsentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TermsConsentRequestBuilder();
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


