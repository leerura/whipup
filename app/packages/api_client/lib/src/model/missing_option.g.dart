// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MissingOption extends MissingOption {
  @override
  final String requiredName;
  @override
  final BuiltList<MissingSubstitute> substitutes;

  factory _$MissingOption([void Function(MissingOptionBuilder)? updates]) =>
      (MissingOptionBuilder()..update(updates))._build();

  _$MissingOption._({required this.requiredName, required this.substitutes})
      : super._();
  @override
  MissingOption rebuild(void Function(MissingOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MissingOptionBuilder toBuilder() => MissingOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MissingOption &&
        requiredName == other.requiredName &&
        substitutes == other.substitutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requiredName.hashCode);
    _$hash = $jc(_$hash, substitutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MissingOption')
          ..add('requiredName', requiredName)
          ..add('substitutes', substitutes))
        .toString();
  }
}

class MissingOptionBuilder
    implements Builder<MissingOption, MissingOptionBuilder> {
  _$MissingOption? _$v;

  String? _requiredName;
  String? get requiredName => _$this._requiredName;
  set requiredName(String? requiredName) => _$this._requiredName = requiredName;

  ListBuilder<MissingSubstitute>? _substitutes;
  ListBuilder<MissingSubstitute> get substitutes =>
      _$this._substitutes ??= ListBuilder<MissingSubstitute>();
  set substitutes(ListBuilder<MissingSubstitute>? substitutes) =>
      _$this._substitutes = substitutes;

  MissingOptionBuilder() {
    MissingOption._defaults(this);
  }

  MissingOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requiredName = $v.requiredName;
      _substitutes = $v.substitutes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MissingOption other) {
    _$v = other as _$MissingOption;
  }

  @override
  void update(void Function(MissingOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MissingOption build() => _build();

  _$MissingOption _build() {
    _$MissingOption _$result;
    try {
      _$result = _$v ??
          _$MissingOption._(
            requiredName: BuiltValueNullFieldError.checkNotNull(
                requiredName, r'MissingOption', 'requiredName'),
            substitutes: substitutes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'substitutes';
        substitutes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MissingOption', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
