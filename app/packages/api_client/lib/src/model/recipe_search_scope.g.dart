// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_search_scope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RecipeSearchScope _$AVAILABLE = const RecipeSearchScope._('AVAILABLE');
const RecipeSearchScope _$ALL = const RecipeSearchScope._('ALL');

RecipeSearchScope _$valueOf(String name) {
  switch (name) {
    case 'AVAILABLE':
      return _$AVAILABLE;
    case 'ALL':
      return _$ALL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RecipeSearchScope> _$values =
    BuiltSet<RecipeSearchScope>(const <RecipeSearchScope>[
  _$AVAILABLE,
  _$ALL,
]);

class _$RecipeSearchScopeMeta {
  const _$RecipeSearchScopeMeta();
  RecipeSearchScope get AVAILABLE => _$AVAILABLE;
  RecipeSearchScope get ALL => _$ALL;
  RecipeSearchScope valueOf(String name) => _$valueOf(name);
  BuiltSet<RecipeSearchScope> get values => _$values;
}

abstract class _$RecipeSearchScopeMixin {
  // ignore: non_constant_identifier_names
  _$RecipeSearchScopeMeta get RecipeSearchScope =>
      const _$RecipeSearchScopeMeta();
}

Serializer<RecipeSearchScope> _$recipeSearchScopeSerializer =
    _$RecipeSearchScopeSerializer();

class _$RecipeSearchScopeSerializer
    implements PrimitiveSerializer<RecipeSearchScope> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'AVAILABLE': 'AVAILABLE',
    'ALL': 'ALL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'AVAILABLE': 'AVAILABLE',
    'ALL': 'ALL',
  };

  @override
  final Iterable<Type> types = const <Type>[RecipeSearchScope];
  @override
  final String wireName = 'RecipeSearchScope';

  @override
  Object serialize(Serializers serializers, RecipeSearchScope object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RecipeSearchScope deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RecipeSearchScope.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
