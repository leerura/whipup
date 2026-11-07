import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/presentation/onboarding_entry.dart';

void main() {
  group('onboardingEntryFor', () {
    test('keeps an incomplete account in initial ingredient registration', () {
      expect(
        onboardingEntryFor(onboardingCompleted: false),
        OnboardingEntry.initialIngredientRegistration,
      );
    });

    test('opens Home for a completed account even with an empty inventory', () {
      expect(
        onboardingEntryFor(onboardingCompleted: true),
        OnboardingEntry.home,
      );
    });
  });
}
