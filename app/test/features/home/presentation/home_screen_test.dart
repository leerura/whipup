import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets(
    'empty inventory shows empty Home without loading recommendations',
    (tester) async {
      final requestedPaths = <String>[];
      var homeTaps = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://whipup.test'));
      final apiClient = ApiClient(dio: dio, interceptors: const []);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPaths.add(options.path);
            if (options.path == '/api/v1/me/ingredients') {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'items': <Object>[]},
                ),
              );
              return;
            }
            handler.reject(
              DioException(
                requestOptions: options,
                message: 'Unexpected request to ${options.path}',
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            apiClient: apiClient,
            onHomeSelected: () => homeTaps++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('재료함이 비어 있어요'), findsOneWidget);
      expect(requestedPaths, ['/api/v1/me/ingredients']);
      await tester.tap(find.text('whippy'));
      expect(homeTaps, 1);
    },
  );

  testWidgets('empty Home scrolls between fixed header and bottom navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var registerTaps = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://whipup.test'));
    final apiClient = ApiClient(dio: dio, interceptors: const []);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {'items': <Object>[]},
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          apiClient: apiClient,
          onIngredientsSelected: () => registerTaps++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('whippy'), findsOneWidget);
    expect(find.text('재료'), findsOneWidget);

    await tester.ensureVisible(find.text('재료 다시 담기'));
    await tester.tap(find.text('재료 다시 담기'));
    expect(registerTaps, 1);
    expect(find.text('whippy'), findsOneWidget);
    expect(find.text('재료'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(find.text('재료는 언제든 다시 수정할 수 있어요.'), findsOneWidget);
  });

  testWidgets('inventory summary uses the same white bordered card surface', (
    tester,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://whipup.test'));
    final apiClient = ApiClient(dio: dio, interceptors: const []);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final data = switch (options.path) {
            '/api/v1/me/ingredients' => {
              'items': [
                {'userIngredientId': 10, 'variantId': 1, 'name': '대파'},
              ],
            },
            '/api/v1/recipes/recommendations' => {'items': <Object>[]},
            _ => <String, dynamic>{},
          };
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: data,
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(apiClient: apiClient)),
    );
    await tester.pumpAndSettle();

    final summaryContainer = tester.widget<Container>(
      find
          .ancestor(of: find.text('내 재료함'), matching: find.byType(Container))
          .first,
    );
    final decoration = summaryContainer.decoration! as BoxDecoration;
    expect(decoration.color, Colors.white);
    expect(decoration.border, isNotNull);
    expect(decoration.borderRadius, BorderRadius.circular(12));
  });
}
