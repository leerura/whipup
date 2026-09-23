import 'package:flutter/material.dart';

import '../../ingredient/presentation/initial_ingredient_screen.dart';
import '../../ingredients/presentation/owned_ingredients_screen.dart';
import '../../recommendation/presentation/recommendation_screen.dart';
import 'kakao_login_screen.dart';
import 'onboarding_intro_screen.dart';
import 'splash_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    this.onKakaoLogin,
    super.key,
  });

  final VoidCallback? onKakaoLogin;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  _OnboardingStage _stage = _OnboardingStage.splash;
  Set<String> _registeredIngredients = const {};

  @override
  void initState() {
    super.initState();
    _advanceToLogin();
  }

  Future<void> _advanceToLogin() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() => _stage = _OnboardingStage.intro);

    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    setState(() => _stage = _OnboardingStage.login);
  }

  void _handleKakaoLogin() {
    widget.onKakaoLogin?.call();
    if (!mounted) return;

    setState(() => _stage = _OnboardingStage.ingredients);
  }

  void _handleIngredientsSubmitted(Set<String> ingredients) {
    _registeredIngredients = Set<String>.unmodifiable(ingredients);
  }

  void _handleOwnedIngredientsChanged(Set<String> ingredients) {
    _registeredIngredients = Set<String>.unmodifiable(ingredients);
  }

  void _showRecommendations() {
    setState(() => _stage = _OnboardingStage.recommendations);
  }

  void _showIngredients() {
    setState(() => _stage = _OnboardingStage.ingredients);
  }

  void _showOwnedIngredients() {
    setState(() => _stage = _OnboardingStage.ownedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: switch (_stage) {
        _OnboardingStage.splash => const SplashScreen(
          key: ValueKey(_OnboardingStage.splash),
        ),
        _OnboardingStage.intro => const OnboardingIntroScreen(
          key: ValueKey(_OnboardingStage.intro),
        ),
        _OnboardingStage.login => KakaoLoginScreen(
          key: const ValueKey(_OnboardingStage.login),
          onKakaoLogin: _handleKakaoLogin,
        ),
        _OnboardingStage.ingredients => InitialIngredientScreen(
          key: const ValueKey(_OnboardingStage.ingredients),
          onSubmit: _handleIngredientsSubmitted,
          onViewRecommendations: _showRecommendations,
        ),
        _OnboardingStage.recommendations => RecommendationScreen(
          key: const ValueKey(_OnboardingStage.recommendations),
          ownedIngredientCount: _registeredIngredients.length,
          onRegisterIngredients: _showIngredients,
          onIngredientsSelected: _showOwnedIngredients,
        ),
        _OnboardingStage.ownedIngredients => OwnedIngredientsScreen(
          key: const ValueKey(_OnboardingStage.ownedIngredients),
          initialOwnedIngredients: _registeredIngredients,
          onOwnedIngredientsChanged: _handleOwnedIngredientsChanged,
          onRecommendationsSelected: _showRecommendations,
        ),
      },
    );
  }
}

enum _OnboardingStage {
  splash,
  intro,
  login,
  ingredients,
  recommendations,
  ownedIngredients,
}
