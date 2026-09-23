// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kakao_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KakaoLoginRequest extends KakaoLoginRequest {
  @override
  final String kakaoAccessToken;

  factory _$KakaoLoginRequest(
          [void Function(KakaoLoginRequestBuilder)? updates]) =>
      (KakaoLoginRequestBuilder()..update(updates))._build();

  _$KakaoLoginRequest._({required this.kakaoAccessToken}) : super._();
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
        kakaoAccessToken == other.kakaoAccessToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kakaoAccessToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KakaoLoginRequest')
          ..add('kakaoAccessToken', kakaoAccessToken))
        .toString();
  }
}

class KakaoLoginRequestBuilder
    implements Builder<KakaoLoginRequest, KakaoLoginRequestBuilder> {
  _$KakaoLoginRequest? _$v;

  String? _kakaoAccessToken;
  String? get kakaoAccessToken => _$this._kakaoAccessToken;
  set kakaoAccessToken(String? kakaoAccessToken) =>
      _$this._kakaoAccessToken = kakaoAccessToken;

  KakaoLoginRequestBuilder() {
    KakaoLoginRequest._defaults(this);
  }

  KakaoLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kakaoAccessToken = $v.kakaoAccessToken;
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
          kakaoAccessToken: BuiltValueNullFieldError.checkNotNull(
              kakaoAccessToken, r'KakaoLoginRequest', 'kakaoAccessToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
