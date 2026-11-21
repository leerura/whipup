// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_consent_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TermsConsentRequest extends TermsConsentRequest {
  @override
  final String termsVersion;
  @override
  final String privacyVersion;
  @override
  final bool age14OrOver;

  factory _$TermsConsentRequest(
          [void Function(TermsConsentRequestBuilder)? updates]) =>
      (TermsConsentRequestBuilder()..update(updates))._build();

  _$TermsConsentRequest._(
      {required this.termsVersion,
      required this.privacyVersion,
      required this.age14OrOver})
      : super._();
  @override
  TermsConsentRequest rebuild(
          void Function(TermsConsentRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TermsConsentRequestBuilder toBuilder() =>
      TermsConsentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TermsConsentRequest &&
        termsVersion == other.termsVersion &&
        privacyVersion == other.privacyVersion &&
        age14OrOver == other.age14OrOver;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, termsVersion.hashCode);
    _$hash = $jc(_$hash, privacyVersion.hashCode);
    _$hash = $jc(_$hash, age14OrOver.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TermsConsentRequest')
          ..add('termsVersion', termsVersion)
          ..add('privacyVersion', privacyVersion)
          ..add('age14OrOver', age14OrOver))
        .toString();
  }
}

class TermsConsentRequestBuilder
    implements Builder<TermsConsentRequest, TermsConsentRequestBuilder> {
  _$TermsConsentRequest? _$v;

  String? _termsVersion;
  String? get termsVersion => _$this._termsVersion;
  set termsVersion(String? termsVersion) => _$this._termsVersion = termsVersion;

  String? _privacyVersion;
  String? get privacyVersion => _$this._privacyVersion;
  set privacyVersion(String? privacyVersion) =>
      _$this._privacyVersion = privacyVersion;

  bool? _age14OrOver;
  bool? get age14OrOver => _$this._age14OrOver;
  set age14OrOver(bool? age14OrOver) => _$this._age14OrOver = age14OrOver;

  TermsConsentRequestBuilder() {
    TermsConsentRequest._defaults(this);
  }

  TermsConsentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _termsVersion = $v.termsVersion;
      _privacyVersion = $v.privacyVersion;
      _age14OrOver = $v.age14OrOver;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TermsConsentRequest other) {
    _$v = other as _$TermsConsentRequest;
  }

  @override
  void update(void Function(TermsConsentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TermsConsentRequest build() => _build();

  _$TermsConsentRequest _build() {
    final _$result = _$v ??
        _$TermsConsentRequest._(
          termsVersion: BuiltValueNullFieldError.checkNotNull(
              termsVersion, r'TermsConsentRequest', 'termsVersion'),
          privacyVersion: BuiltValueNullFieldError.checkNotNull(
              privacyVersion, r'TermsConsentRequest', 'privacyVersion'),
          age14OrOver: BuiltValueNullFieldError.checkNotNull(
              age14OrOver, r'TermsConsentRequest', 'age14OrOver'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
