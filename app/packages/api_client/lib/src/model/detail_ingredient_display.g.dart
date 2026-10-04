// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_ingredient_display.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DetailIngredientDisplay extends DetailIngredientDisplay {
  @override
  final String displayName;
  @override
  final String rawText;
  @override
  final String? amount;
  @override
  final String? unit;

  factory _$DetailIngredientDisplay(
          [void Function(DetailIngredientDisplayBuilder)? updates]) =>
      (DetailIngredientDisplayBuilder()..update(updates))._build();

  _$DetailIngredientDisplay._(
      {required this.displayName,
      required this.rawText,
      this.amount,
      this.unit})
      : super._();
  @override
  DetailIngredientDisplay rebuild(
          void Function(DetailIngredientDisplayBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DetailIngredientDisplayBuilder toBuilder() =>
      DetailIngredientDisplayBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DetailIngredientDisplay &&
        displayName == other.displayName &&
        rawText == other.rawText &&
        amount == other.amount &&
        unit == other.unit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, rawText.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DetailIngredientDisplay')
          ..add('displayName', displayName)
          ..add('rawText', rawText)
          ..add('amount', amount)
          ..add('unit', unit))
        .toString();
  }
}

class DetailIngredientDisplayBuilder
    implements
        Builder<DetailIngredientDisplay, DetailIngredientDisplayBuilder> {
  _$DetailIngredientDisplay? _$v;

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

  DetailIngredientDisplayBuilder() {
    DetailIngredientDisplay._defaults(this);
  }

  DetailIngredientDisplayBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _rawText = $v.rawText;
      _amount = $v.amount;
      _unit = $v.unit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DetailIngredientDisplay other) {
    _$v = other as _$DetailIngredientDisplay;
  }

  @override
  void update(void Function(DetailIngredientDisplayBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DetailIngredientDisplay build() => _build();

  _$DetailIngredientDisplay _build() {
    final _$result = _$v ??
        _$DetailIngredientDisplay._(
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'DetailIngredientDisplay', 'displayName'),
          rawText: BuiltValueNullFieldError.checkNotNull(
              rawText, r'DetailIngredientDisplay', 'rawText'),
          amount: amount,
          unit: unit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
