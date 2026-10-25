import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ingredients/presentation/owned_ingredients_screen.dart';

void main() {
  testWidgets('tapping the logo returns to Home', (tester) async {
    var homeTaps = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://whipup.test'));
    final apiClient = ApiClient(dio: dio, interceptors: const []);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final data = options.path == '/api/v1/ingredients'
              ? {'groups': <Object>[]}
              : {'items': <Object>[]};
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
      MaterialApp(
        home: OwnedIngredientsScreen(
          apiClient: apiClient,
          onHomeSelected: () => homeTaps++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('whippy'), findsOneWidget);
    expect(find.byTooltip('알림'), findsNothing);
    expect(find.byIcon(Icons.person_rounded), findsNothing);

    await tester.tap(find.text('whippy'));
    expect(homeTaps, 1);
  });
}
