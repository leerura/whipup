import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for OnboardingApi
void main() {
  final instance = ApiClient().getOnboardingApi();

  group(OnboardingApi, () {
    //Future completeOnboarding(OnboardingRequest onboardingRequest) async
    test('test completeOnboarding', () async {
      // TODO
    });

  });
}
