import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/recommendation/presentation/recommendation_screen.dart';

Map<String, Object?> _item(int id, String name) => {
  'recipeId': id,
  'name': name,
  'thumbnailUrl': 'https://whipup.test/$id.jpg',
  'missingCount': 0,
  'requirementResults': <Object?>[],
};

Dio _dioWithHandler(
  Future<Response<Object?>> Function(RequestOptions options) respond,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://whipup.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          handler.resolve(await respond(options));
        } on DioException catch (error) {
          handler.reject(error);
        }
      },
    ),
  );
  return dio;
}

void _useNarrowPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

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

  testWidgets(
    'refreshRevision reloads quietly: list stays until new data arrives',
    (tester) async {
      _useNarrowPhone(tester);
      var calls = 0;
      final second = Completer<Response<Object?>>();
      final dio = _dioWithHandler((options) {
        calls++;
        if (calls == 1) {
          return Future.value(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [_item(1, '계란볶음밥')],
              },
            ),
          );
        }
        return second.future;
      });
      final apiClient = ApiClient(dio: dio, interceptors: const []);

      Widget build(int revision) => MaterialApp(
        home: RecommendationScreen(
          apiClient: apiClient,
          ownedIngredientCount: 3,
          refreshRevision: revision,
        ),
      );

      await tester.pumpWidget(build(0));
      await tester.pumpAndSettle();
      expect(find.text('계란볶음밥'), findsOneWidget);

      await tester.pumpWidget(build(1));
      // Dio가 요청을 내보내도록 시간을 조금 흘린다(응답은 아직 오지 않는다).
      await tester.pump(const Duration(milliseconds: 50));

      // 새 응답을 기다리는 동안에도 기존 목록이 그대로 보이고 로딩 표시로 바뀌지 않는다.
      expect(calls, 2);
      expect(find.text('계란볶음밥'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      second.complete(
        Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
          data: {
            'items': [_item(2, '김치볶음밥')],
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('김치볶음밥'), findsOneWidget);
      expect(find.text('계란볶음밥'), findsNothing);
    },
  );

  testWidgets('refresh failure keeps the current list without an error state', (
    tester,
  ) async {
    _useNarrowPhone(tester);
    var calls = 0;
    final dio = _dioWithHandler((options) async {
      calls++;
      if (calls == 1) {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'items': [_item(1, '계란볶음밥')],
          },
        );
      }
      throw DioException(requestOptions: options, message: 'network down');
    });
    final apiClient = ApiClient(dio: dio, interceptors: const []);

    Widget build(int revision) => MaterialApp(
      home: RecommendationScreen(
        apiClient: apiClient,
        ownedIngredientCount: 3,
        refreshRevision: revision,
      ),
    );

    await tester.pumpWidget(build(0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(build(1));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('계란볶음밥'), findsOneWidget);
    expect(find.text('추천 메뉴를 불러오지 못했어요'), findsNothing);
  });

  testWidgets('same refreshRevision does not trigger another request', (
    tester,
  ) async {
    _useNarrowPhone(tester);
    var calls = 0;
    final dio = _dioWithHandler((options) async {
      calls++;
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'items': [_item(1, '계란볶음밥')],
        },
      );
    });
    final apiClient = ApiClient(dio: dio, interceptors: const []);
    Widget build() => MaterialApp(
      home: RecommendationScreen(
        apiClient: apiClient,
        ownedIngredientCount: 3,
        refreshRevision: 0,
      ),
    );

    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    expect(calls, 1);
  });
}
