import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for TelemetryApi
void main() {
  final instance = ApiClient().getTelemetryApi();

  group(TelemetryApi, () {
    // Aggregates authenticated client HTTP timing without storing raw events.
    //
    //Future recordHttpTiming(HttpTimingRequest httpTimingRequest) async
    test('test recordHttpTiming', () async {
      // TODO
    });

  });
}
