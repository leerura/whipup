// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kakao_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KakaoLoginRequest extends KakaoLoginRequest {
  @override
  final String authorizationCode;

  factory _$KakaoLoginRequest(
          [void Function(KakaoLoginRequestBuilder)? updates]) =>
      (KakaoLoginRequestBuilder()..update(updates))._build();

  _$KakaoLoginRequest._({required this.authorizationCode}) : super._();
  @override
  KakaoLoginRequest rebuild(void Function(KakaoLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KakaoLoginRequestBuilder toBuilder() =>
      KakaoLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KakaoLoginRequest &&
        authorizationCode == other.authorizationCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, authorizationCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KakaoLoginRequest')
          ..add('authorizationCode', authorizationCode))
        .toString();
  }
}

class KakaoLoginRequestBuilder
    implements Builder<KakaoLoginRequest, KakaoLoginRequestBuilder> {
  _$KakaoLoginRequest? _$v;

  String? _authorizationCode;
  String? get authorizationCode => _$this._authorizationCode;
  set authorizationCode(String? authorizationCode) =>
      _$this._authorizationCode = authorizationCode;

  KakaoLoginRequestBuilder() {
    KakaoLoginRequest._defaults(this);
  }

  KakaoLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _authorizationCode = $v.authorizationCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KakaoLoginRequest other) {
    _$v = other as _$KakaoLoginRequest;
  }

  @override
  void update(void Function(KakaoLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KakaoLoginRequest build() => _build();

  _$KakaoLoginRequest _build() {
    final _$result = _$v ??
        _$KakaoLoginRequest._(
          authorizationCode: BuiltValueNullFieldError.checkNotNull(
              authorizationCode, r'KakaoLoginRequest', 'authorizationCode'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
