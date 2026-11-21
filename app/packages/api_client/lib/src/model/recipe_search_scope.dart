//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recipe_search_scope.g.dart';

class RecipeSearchScope extends EnumClass {

  @BuiltValueEnumConst(wireName: r'AVAILABLE')
  static const RecipeSearchScope AVAILABLE = _$AVAILABLE;
  @BuiltValueEnumConst(wireName: r'ALL')
  static const RecipeSearchScope ALL = _$ALL;

  static Serializer<RecipeSearchScope> get serializer => _$recipeSearchScopeSerializer;

  const RecipeSearchScope._(String name): super(name);

  static BuiltSet<RecipeSearchScope> get values => _$values;
  static RecipeSearchScope valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RecipeSearchScopeMixin = Object with _$RecipeSearchScopeMixin;

