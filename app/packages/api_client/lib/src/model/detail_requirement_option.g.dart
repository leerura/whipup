// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_requirement_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DetailRequirementOption extends DetailRequirementOption {
  @override
  final String displayName;
  @override
  final String rawText;
  @override
  final String? amount;
  @override
  final String? unit;
  @override
  final BuiltList<DetailIngredientDisplay> substitutes;

  factory _$DetailRequirementOption(
          [void Function(DetailRequirementOptionBuilder)? updates]) =>
      (DetailRequirementOptionBuilder()..update(updates))._build();

  _$DetailRequirementOption._(
      {required this.displayName,
      required this.rawText,
      this.amount,
      this.unit,
      required this.substitutes})
      : super._();
  @override
  DetailRequirementOption rebuild(
          void Function(DetailRequirementOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DetailRequirementOptionBuilder toBuilder() =>
      DetailRequirementOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DetailRequirementOption &&
        displayName == other.displayName &&
        rawText == other.rawText &&
        amount == other.amount &&
        unit == other.unit &&
        substitutes == other.substitutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, rawText.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, substitutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DetailRequirementOption')
          ..add('displayName', displayName)
          ..add('rawText', rawText)
          ..add('amount', amount)
          ..add('unit', unit)
          ..add('substitutes', substitutes))
        .toString();
  }
}

class DetailRequirementOptionBuilder
    implements
        Builder<DetailRequirementOption, DetailRequirementOptionBuilder> {
  _$DetailRequirementOption? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _rawText;
  String? get rawText => _$this._rawText;
  set rawText(String? rawText) => _$this._rawText = rawText;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  ListBuilder<DetailIngredientDisplay>? _substitutes;
  ListBuilder<DetailIngredientDisplay> get substitutes =>
      _$this._substitutes ??= ListBuilder<DetailIngredientDisplay>();
  set substitutes(ListBuilder<DetailIngredientDisplay>? substitutes) =>
      _$this._substitutes = substitutes;

  DetailRequirementOptionBuilder() {
    DetailRequirementOption._defaults(this);
  }

  DetailRequirementOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _rawText = $v.rawText;
      _amount = $v.amount;
      _unit = $v.unit;
      _substitutes = $v.substitutes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DetailRequirementOption other) {
    _$v = other as _$DetailRequirementOption;
  }

  @override
  void update(void Function(DetailRequirementOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DetailRequirementOption build() => _build();

  _$DetailRequirementOption _build() {
    _$DetailRequirementOption _$result;
    try {
      _$result = _$v ??
          _$DetailRequirementOption._(
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'DetailRequirementOption', 'displayName'),
            rawText: BuiltValueNullFieldError.checkNotNull(
                rawText, r'DetailRequirementOption', 'rawText'),
            amount: amount,
            unit: unit,
            substitutes: substitutes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'substitutes';
        substitutes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DetailRequirementOption', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
