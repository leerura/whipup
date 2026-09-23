import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for IngredientApi
void main() {
  final instance = ApiClient().getIngredientApi();

  group(IngredientApi, () {
    //Future<IngredientOptionListResponse> getIngredientOptions() async
    test('test getIngredientOptions', () async {
      // TODO
    });

  });
}
