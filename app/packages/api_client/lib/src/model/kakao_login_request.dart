//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kakao_login_request.g.dart';

/// KakaoLoginRequest
///
/// Properties:
/// * [kakaoAccessToken] 
@BuiltValue()
abstract class KakaoLoginRequest implements Built<KakaoLoginRequest, KakaoLoginRequestBuilder> {
  @BuiltValueField(wireName: r'kakaoAccessToken')
  String get kakaoAccessToken;

  KakaoLoginRequest._();

  factory KakaoLoginRequest([void updates(KakaoLoginRequestBuilder b)]) = _$KakaoLoginRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KakaoLoginRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KakaoLoginRequest> get serializer => _$KakaoLoginRequestSerializer();
}

class _$KakaoLoginRequestSerializer implements PrimitiveSerializer<KakaoLoginRequest> {
  @override
  final Iterable<Type> types = const [KakaoLoginRequest, _$KakaoLoginRequest];

  @override
  final String wireName = r'KakaoLoginRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KakaoLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kakaoAccessToken';
    yield serializers.serialize(
      object.kakaoAccessToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KakaoLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required KakaoLoginRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kakaoAccessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kakaoAccessToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KakaoLoginRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KakaoLoginRequestBuilder();
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


