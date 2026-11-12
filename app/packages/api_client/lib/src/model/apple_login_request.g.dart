// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppleLoginRequest extends AppleLoginRequest {
  @override
  final String identityToken;
  @override
  final String authorizationCode;
  @override
  final String nonce;

  factory _$AppleLoginRequest(
          [void Function(AppleLoginRequestBuilder)? updates]) =>
      (AppleLoginRequestBuilder()..update(updates))._build();

  _$AppleLoginRequest._(
      {required this.identityToken,
      required this.authorizationCode,
      required this.nonce})
      : super._();
  @override
  AppleLoginRequest rebuild(void Function(AppleLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppleLoginRequestBuilder toBuilder() =>
      AppleLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppleLoginRequest &&
        identityToken == other.identityToken &&
        authorizationCode == other.authorizationCode &&
        nonce == other.nonce;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, identityToken.hashCode);
    _$hash = $jc(_$hash, authorizationCode.hashCode);
    _$hash = $jc(_$hash, nonce.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppleLoginRequest')
          ..add('identityToken', identityToken)
          ..add('authorizationCode', authorizationCode)
          ..add('nonce', nonce))
        .toString();
  }
}

class AppleLoginRequestBuilder
    implements Builder<AppleLoginRequest, AppleLoginRequestBuilder> {
  _$AppleLoginRequest? _$v;

  String? _identityToken;
  String? get identityToken => _$this._identityToken;
  set identityToken(String? identityToken) =>
      _$this._identityToken = identityToken;

  String? _authorizationCode;
  String? get authorizationCode => _$this._authorizationCode;
  set authorizationCode(String? authorizationCode) =>
      _$this._authorizationCode = authorizationCode;

  String? _nonce;
  String? get nonce => _$this._nonce;
  set nonce(String? nonce) => _$this._nonce = nonce;

  AppleLoginRequestBuilder() {
    AppleLoginRequest._defaults(this);
  }

  AppleLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _identityToken = $v.identityToken;
      _authorizationCode = $v.authorizationCode;
      _nonce = $v.nonce;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppleLoginRequest other) {
    _$v = other as _$AppleLoginRequest;
  }

  @override
  void update(void Function(AppleLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppleLoginRequest build() => _build();

  _$AppleLoginRequest _build() {
    final _$result = _$v ??
        _$AppleLoginRequest._(
          identityToken: BuiltValueNullFieldError.checkNotNull(
              identityToken, r'AppleLoginRequest', 'identityToken'),
          authorizationCode: BuiltValueNullFieldError.checkNotNull(
              authorizationCode, r'AppleLoginRequest', 'authorizationCode'),
          nonce: BuiltValueNullFieldError.checkNotNull(
              nonce, r'AppleLoginRequest', 'nonce'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
