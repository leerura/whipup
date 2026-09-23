import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for RecipeApi
void main() {
  final instance = ApiClient().getRecipeApi();

  group(RecipeApi, () {
    //Future<RecipeDetailResponse> getRecipeDetail(int recipeId) async
    test('test getRecipeDetail', () async {
      // TODO
    });

  });
}
