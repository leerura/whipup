import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for DailyMenuApi
void main() {
  final instance = ApiClient().getDailyMenuApi();

  group(DailyMenuApi, () {
    //Future addDailyMenu(DailyMenuRequest dailyMenuRequest) async
    test('test addDailyMenu', () async {
      // TODO
    });

    //Future<RecommendationListResponse> getDailyMenu() async
    test('test getDailyMenu', () async {
      // TODO
    });

    //Future removeDailyMenu(int recipeId) async
    test('test removeDailyMenu', () async {
      // TODO
    });

  });
}
