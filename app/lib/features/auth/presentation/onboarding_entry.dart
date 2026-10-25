enum OnboardingEntry { initialIngredientRegistration, home }

OnboardingEntry onboardingEntryFor({required bool onboardingCompleted}) {
  return onboardingCompleted
      ? OnboardingEntry.home
      : OnboardingEntry.initialIngredientRegistration;
}
