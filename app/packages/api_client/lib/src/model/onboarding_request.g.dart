// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OnboardingRequest extends OnboardingRequest {
  @override
  final BuiltSet<int> variantIds;

  factory _$OnboardingRequest(
          [void Function(OnboardingRequestBuilder)? updates]) =>
      (OnboardingRequestBuilder()..update(updates))._build();

  _$OnboardingRequest._({required this.variantIds}) : super._();
  @override
  OnboardingRequest rebuild(void Function(OnboardingRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OnboardingRequestBuilder toBuilder() =>
      OnboardingRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OnboardingRequest && variantIds == other.variantIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OnboardingRequest')
          ..add('variantIds', variantIds))
        .toString();
  }
}

class OnboardingRequestBuilder
    implements Builder<OnboardingRequest, OnboardingRequestBuilder> {
  _$OnboardingRequest? _$v;

  SetBuilder<int>? _variantIds;
  SetBuilder<int> get variantIds => _$this._variantIds ??= SetBuilder<int>();
  set variantIds(SetBuilder<int>? variantIds) =>
      _$this._variantIds = variantIds;

  OnboardingRequestBuilder() {
    OnboardingRequest._defaults(this);
  }

  OnboardingRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantIds = $v.variantIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OnboardingRequest other) {
    _$v = other as _$OnboardingRequest;
  }

  @override
  void update(void Function(OnboardingRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OnboardingRequest build() => _build();

  _$OnboardingRequest _build() {
    _$OnboardingRequest _$result;
    try {
      _$result = _$v ??
          _$OnboardingRequest._(
            variantIds: variantIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'variantIds';
        variantIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OnboardingRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
