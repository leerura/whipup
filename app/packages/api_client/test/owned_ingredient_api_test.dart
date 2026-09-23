import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for OwnedIngredientApi
void main() {
  final instance = ApiClient().getOwnedIngredientApi();

  group(OwnedIngredientApi, () {
    //Future<OwnedIngredientListResponse> addOwnedIngredients(AddOwnedIngredientsRequest addOwnedIngredientsRequest) async
    test('test addOwnedIngredients', () async {
      // TODO
    });

    //Future deleteOwnedIngredient(int userIngredientId) async
    test('test deleteOwnedIngredient', () async {
      // TODO
    });

    //Future<OwnedIngredientListResponse> getOwnedIngredients() async
    test('test getOwnedIngredients', () async {
      // TODO
    });

  });
}
