// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_account_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CurrentAccountResponse extends CurrentAccountResponse {
  @override
  final UserSummary user;
  @override
  final bool hasOwnedIngredients;
  @override
  final bool onboardingCompleted;
  @override
  final bool termsConsentRequired;

  factory _$CurrentAccountResponse(
          [void Function(CurrentAccountResponseBuilder)? updates]) =>
      (CurrentAccountResponseBuilder()..update(updates))._build();

  _$CurrentAccountResponse._(
      {required this.user,
      required this.hasOwnedIngredients,
      required this.onboardingCompleted,
      required this.termsConsentRequired})
      : super._();
  @override
  CurrentAccountResponse rebuild(
          void Function(CurrentAccountResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CurrentAccountResponseBuilder toBuilder() =>
      CurrentAccountResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CurrentAccountResponse &&
        user == other.user &&
        hasOwnedIngredients == other.hasOwnedIngredients &&
        onboardingCompleted == other.onboardingCompleted &&
        termsConsentRequired == other.termsConsentRequired;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, hasOwnedIngredients.hashCode);
    _$hash = $jc(_$hash, onboardingCompleted.hashCode);
    _$hash = $jc(_$hash, termsConsentRequired.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CurrentAccountResponse')
          ..add('user', user)
          ..add('hasOwnedIngredients', hasOwnedIngredients)
          ..add('onboardingCompleted', onboardingCompleted)
          ..add('termsConsentRequired', termsConsentRequired))
        .toString();
  }
}

class CurrentAccountResponseBuilder
    implements Builder<CurrentAccountResponse, CurrentAccountResponseBuilder> {
  _$CurrentAccountResponse? _$v;

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

  bool? _termsConsentRequired;
  bool? get termsConsentRequired => _$this._termsConsentRequired;
  set termsConsentRequired(bool? termsConsentRequired) =>
      _$this._termsConsentRequired = termsConsentRequired;

  CurrentAccountResponseBuilder() {
    CurrentAccountResponse._defaults(this);
  }

  CurrentAccountResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _hasOwnedIngredients = $v.hasOwnedIngredients;
      _onboardingCompleted = $v.onboardingCompleted;
      _termsConsentRequired = $v.termsConsentRequired;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CurrentAccountResponse other) {
    _$v = other as _$CurrentAccountResponse;
  }

  @override
  void update(void Function(CurrentAccountResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CurrentAccountResponse build() => _build();

  _$CurrentAccountResponse _build() {
    _$CurrentAccountResponse _$result;
    try {
      _$result = _$v ??
          _$CurrentAccountResponse._(
            user: user.build(),
            hasOwnedIngredients: BuiltValueNullFieldError.checkNotNull(
                hasOwnedIngredients,
                r'CurrentAccountResponse',
                'hasOwnedIngredients'),
            onboardingCompleted: BuiltValueNullFieldError.checkNotNull(
                onboardingCompleted,
                r'CurrentAccountResponse',
                'onboardingCompleted'),
            termsConsentRequired: BuiltValueNullFieldError.checkNotNull(
                termsConsentRequired,
                r'CurrentAccountResponse',
                'termsConsentRequired'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CurrentAccountResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
