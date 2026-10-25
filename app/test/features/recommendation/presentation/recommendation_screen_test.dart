import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/recommendation/presentation/recommendation_screen.dart';

void main() {
  testWidgets('empty inventory shows registration state without API request', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final requestedPaths = <String>[];
    var registrationTaps = 0;
    var homeTaps = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://whipup.test'));
    final apiClient = ApiClient(dio: dio, interceptors: const []);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedPaths.add(options.path);
          handler.reject(
            DioException(
              requestOptions: options,
              message: 'Recommendation request should be skipped.',
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecommendationScreen(
          apiClient: apiClient,
          ownedIngredientCount: 0,
          onRegisterIngredients: () => registrationTaps++,
          onHomeSelected: () => homeTaps++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('재료함이 비어 있어요'), findsOneWidget);
    expect(find.text('추천 메뉴를 불러오지 못했어요'), findsNothing);
    expect(find.text('재료 등록하기'), findsOneWidget);
    expect(requestedPaths, isEmpty);

    await tester.ensureVisible(find.text('재료 등록하기'));
    await tester.tap(find.text('재료 등록하기'));
    await tester.tap(find.text('whippy'));
    expect(registrationTaps, 1);
    expect(homeTaps, 1);
  });
}
