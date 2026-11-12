//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apple_login_request.g.dart';

/// AppleLoginRequest
///
/// Properties:
/// * [identityToken] - Apple identity token (JWT) returned to the app.
/// * [authorizationCode] - Short-lived Apple authorization code the server exchanges with Apple.
/// * [nonce] - Raw nonce the app generated; its SHA-256 hex digest was sent to Apple.
@BuiltValue()
abstract class AppleLoginRequest implements Built<AppleLoginRequest, AppleLoginRequestBuilder> {
  /// Apple identity token (JWT) returned to the app.
  @BuiltValueField(wireName: r'identityToken')
  String get identityToken;

  /// Short-lived Apple authorization code the server exchanges with Apple.
  @BuiltValueField(wireName: r'authorizationCode')
  String get authorizationCode;

  /// Raw nonce the app generated; its SHA-256 hex digest was sent to Apple.
  @BuiltValueField(wireName: r'nonce')
  String get nonce;

  AppleLoginRequest._();

  factory AppleLoginRequest([void updates(AppleLoginRequestBuilder b)]) = _$AppleLoginRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppleLoginRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppleLoginRequest> get serializer => _$AppleLoginRequestSerializer();
}

class _$AppleLoginRequestSerializer implements PrimitiveSerializer<AppleLoginRequest> {
  @override
  final Iterable<Type> types = const [AppleLoginRequest, _$AppleLoginRequest];

  @override
  final String wireName = r'AppleLoginRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppleLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'identityToken';
    yield serializers.serialize(
      object.identityToken,
      specifiedType: const FullType(String),
    );
    yield r'authorizationCode';
    yield serializers.serialize(
      object.authorizationCode,
      specifiedType: const FullType(String),
    );
    yield r'nonce';
    yield serializers.serialize(
      object.nonce,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AppleLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppleLoginRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'identityToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.identityToken = valueDes;
          break;
        case r'authorizationCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorizationCode = valueDes;
          break;
        case r'nonce':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nonce = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppleLoginRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppleLoginRequestBuilder();
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


