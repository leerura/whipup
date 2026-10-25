// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginResponse extends LoginResponse {
  @override
  final String accessToken;
  @override
  final UserSummary user;
  @override
  final bool hasOwnedIngredients;
  @override
  final bool onboardingCompleted;

  factory _$LoginResponse([void Function(LoginResponseBuilder)? updates]) =>
      (LoginResponseBuilder()..update(updates))._build();

  _$LoginResponse._(
      {required this.accessToken,
      required this.user,
      required this.hasOwnedIngredients,
      required this.onboardingCompleted})
      : super._();
  @override
  LoginResponse rebuild(void Function(LoginResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginResponseBuilder toBuilder() => LoginResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginResponse &&
        accessToken == other.accessToken &&
        user == other.user &&
        hasOwnedIngredients == other.hasOwnedIngredients &&
        onboardingCompleted == other.onboardingCompleted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, hasOwnedIngredients.hashCode);
    _$hash = $jc(_$hash, onboardingCompleted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginResponse')
          ..add('accessToken', accessToken)
          ..add('user', user)
          ..add('hasOwnedIngredients', hasOwnedIngredients)
          ..add('onboardingCompleted', onboardingCompleted))
        .toString();
  }
}

class LoginResponseBuilder
    implements Builder<LoginResponse, LoginResponseBuilder> {
  _$LoginResponse? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  UserSummaryBuilder? _user;
  UserSummaryBuilder get user => _$this._user ??= UserSummaryBuilder();
  set user(UserSummaryBuilder? user) => _$this._user = user;

  bool? _hasOwnedIngredients;
  bool? get hasOwnedIngredients => _$this._hasOwnedIngredients;
  set hasOwnedIngredients(bool? hasOwnedIngredients) =>
      _$this._hasOwnedIngredients = hasOwnedIngredients;

  bool? _onboardingCompleted;
  bool? get onboardingCompleted => _$this._onboardingCompleted;
  set onboardingCompleted(bool? onboardingCompleted) =>
      _$this._onboardingCompleted = onboardingCompleted;

  LoginResponseBuilder() {
    LoginResponse._defaults(this);
  }

  LoginResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _user = $v.user.toBuilder();
      _hasOwnedIngredients = $v.hasOwnedIngredients;
      _onboardingCompleted = $v.onboardingCompleted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginResponse other) {
    _$v = other as _$LoginResponse;
  }

  @override
  void update(void Function(LoginResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginResponse build() => _build();

  _$LoginResponse _build() {
    _$LoginResponse _$result;
    try {
      _$result = _$v ??
          _$LoginResponse._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'LoginResponse', 'accessToken'),
            user: user.build(),
            hasOwnedIngredients: BuiltValueNullFieldError.checkNotNull(
                hasOwnedIngredients, r'LoginResponse', 'hasOwnedIngredients'),
            onboardingCompleted: BuiltValueNullFieldError.checkNotNull(
                onboardingCompleted, r'LoginResponse', 'onboardingCompleted'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LoginResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
