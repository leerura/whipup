import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for RecommendationApi
void main() {
  final instance = ApiClient().getRecommendationApi();

  group(RecommendationApi, () {
    //Future<RecommendationPage> getRecommendations(int missingCount, { int page, int size }) async
    test('test getRecommendations', () async {
      // TODO
    });

  });
}
