import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../core/config/app_config.dart';
import '../../ingredient/presentation/initial_ingredient_screen.dart';
import '../../ingredients/presentation/owned_ingredients_screen.dart';
import '../../recommendation/presentation/recommendation_screen.dart';
import '../../recipe/presentation/recipe_detail_screen.dart';
import 'kakao_login_screen.dart';
import 'onboarding_motion_sequence.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({this.onKakaoLogin, super.key});

  final VoidCallback? onKakaoLogin;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final ApiClient _apiClient = ApiClient(
    basePathOverride: AppConfig.apiBaseUrl,
  );

  _OnboardingStage _stage = _OnboardingStage.splash;
  Set<String> _registeredIngredients = const {};
  bool _isLoggingIn = false;
  bool _hasLoginError = false;

  void _finishOnboardingMotion() {
    setState(() => _stage = _OnboardingStage.login);
  }

  Future<void> _handleKakaoLogin() async {
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _hasLoginError = false;
    });

    try {
      late final OAuthToken kakaoToken;

      if (await isKakaoTalkInstalled()) {
        try {
          kakaoToken = await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          kakaoToken = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
      }

      final response = await _apiClient.getAuthApi().loginWithKakao(
        kakaoLoginRequest: KakaoLoginRequest(
          (builder) => builder.kakaoAccessToken = kakaoToken.accessToken,
        ),
      );
      final loginResponse = response.data;
      if (loginResponse == null) {
        throw StateError('The login response body is empty.');
      }

      _apiClient.setBearerAuth('bearerAuth', loginResponse.accessToken);

      Set<String> registeredIngredients = const {};
      if (loginResponse.hasOwnedIngredients) {
        final response = await _apiClient
            .getOwnedIngredientApi()
            .getOwnedIngredients();
        final data = response.data;
        if (data == null) {
          throw StateError('The owned ingredient response body is empty.');
        }

        registeredIngredients = data.items
            .map((ingredient) => ingredient.displayName)
            .toSet();
      }

      widget.onKakaoLogin?.call();
      if (!mounted) return;

      setState(() {
        _registeredIngredients = Set<String>.unmodifiable(
          registeredIngredients,
        );
        _stage = registeredIngredients.isEmpty
            ? _OnboardingStage.ingredients
            : _OnboardingStage.recommendations;
      });
    } catch (error) {
      debugPrint('Kakao login failed: $error');
      if (!mounted) return;

      setState(() => _hasLoginError = true);
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
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

  void _showRecipeDetail(int recipeId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            RecipeDetailScreen(apiClient: _apiClient, recipeId: recipeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _stage == _OnboardingStage.login
          ? Duration.zero
          : const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: switch (_stage) {
        _OnboardingStage.splash => OnboardingMotionSequence(
          key: const ValueKey(_OnboardingStage.splash),
          onCompleted: _finishOnboardingMotion,
        ),
        _OnboardingStage.login => KakaoLoginScreen(
          key: const ValueKey(_OnboardingStage.login),
          onKakaoLogin: _handleKakaoLogin,
          isLoading: _isLoggingIn,
          hasError: _hasLoginError,
        ),
        _OnboardingStage.ingredients => InitialIngredientScreen(
          key: const ValueKey(_OnboardingStage.ingredients),
          apiClient: _apiClient,
          onSubmit: _handleIngredientsSubmitted,
          onViewRecommendations: _showRecommendations,
        ),
        _OnboardingStage.recommendations => RecommendationScreen(
          key: const ValueKey(_OnboardingStage.recommendations),
          apiClient: _apiClient,
          ownedIngredientCount: _registeredIngredients.length,
          onRegisterIngredients: _showIngredients,
          onIngredientsSelected: _showOwnedIngredients,
          onRecipeSelected: _showRecipeDetail,
        ),
        _OnboardingStage.ownedIngredients => OwnedIngredientsScreen(
          key: const ValueKey(_OnboardingStage.ownedIngredients),
          apiClient: _apiClient,
          onRegisterIngredients: _showIngredients,
          onOwnedIngredientsChanged: _handleOwnedIngredientsChanged,
          onRecommendationsSelected: _showRecommendations,
        ),
      },
    );
  }
}

enum _OnboardingStage {
  splash,
  login,
  ingredients,
  recommendations,
  ownedIngredients,
}
