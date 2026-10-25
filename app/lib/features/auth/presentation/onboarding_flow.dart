import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../core/config/app_config.dart';
import '../../home/presentation/home_screen.dart';
import '../../ingredient/presentation/initial_ingredient_screen.dart';
import '../../ingredients/presentation/owned_ingredients_screen.dart';
import '../../recommendation/presentation/recommendation_screen.dart';
import '../../recipe/presentation/recipe_detail_screen.dart';
import 'onboarding_entry.dart';
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

    var loginStep = 'checking KakaoTalk availability';
    try {
      late final OAuthToken kakaoToken;

      final isTalkInstalled = await isKakaoTalkInstalled();
      debugPrint('[Kakao login] KakaoTalk installed: $isTalkInstalled');
      if (isTalkInstalled) {
        try {
          loginStep = 'KakaoTalk login';
          debugPrint('[Kakao login] Starting KakaoTalk login');
          kakaoToken = await UserApi.instance.loginWithKakaoTalk();
        } catch (error, stackTrace) {
          debugPrint('[Kakao login] KakaoTalk login failed: $error');
          debugPrintStack(
            label: '[Kakao login] KakaoTalk failure stack',
            stackTrace: stackTrace,
          );
          loginStep = 'Kakao Account login after KakaoTalk failure';
          debugPrint('[Kakao login] Falling back to Kakao Account login');
          kakaoToken = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        loginStep = 'Kakao Account login without KakaoTalk';
        debugPrint('[Kakao login] Starting Kakao Account login');
        kakaoToken = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('[Kakao login] SDK login completed');
      loginStep = 'backend token exchange';
      debugPrint('[Kakao login] Starting backend token exchange');
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
      debugPrint('[Kakao login] Backend token exchange completed');

      Set<String> registeredIngredients = const {};
      if (loginResponse.hasOwnedIngredients) {
        loginStep = 'loading owned ingredients';
        final response = await _apiClient
            .getOwnedIngredientApi()
            .getOwnedIngredients();
        final data = response.data;
        if (data == null) {
          throw StateError('The owned ingredient response body is empty.');
        }

        registeredIngredients = data.items
            .map((ingredient) => ingredient.name)
            .toSet();
      }

      widget.onKakaoLogin?.call();
      if (!mounted) return;

      setState(() {
        _registeredIngredients = Set<String>.unmodifiable(
          registeredIngredients,
        );
        _stage = switch (onboardingEntryFor(
          onboardingCompleted: loginResponse.onboardingCompleted,
        )) {
          OnboardingEntry.initialIngredientRegistration =>
            _OnboardingStage.ingredients,
          OnboardingEntry.home => _OnboardingStage.home,
        };
      });
    } catch (error, stackTrace) {
      debugPrint('[Kakao login] Failed during $loginStep: $error');
      debugPrintStack(
        label: '[Kakao login] Failure stack',
        stackTrace: stackTrace,
      );
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

  void _showHome() {
    setState(() => _stage = _OnboardingStage.home);
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
          onRegisterIngredients: _showOwnedIngredients,
          onHomeSelected: _showHome,
          onIngredientsSelected: _showOwnedIngredients,
          onRecipeSelected: _showRecipeDetail,
        ),
        _OnboardingStage.home => HomeScreen(
          key: const ValueKey(_OnboardingStage.home),
          apiClient: _apiClient,
          onHomeSelected: _showHome,
          onIngredientsSelected: _showOwnedIngredients,
          onRecommendationsSelected: _showRecommendations,
          onRecipeSelected: _showRecipeDetail,
        ),
        _OnboardingStage.ownedIngredients => OwnedIngredientsScreen(
          key: const ValueKey(_OnboardingStage.ownedIngredients),
          apiClient: _apiClient,
          onRegisterIngredients: _showOwnedIngredients,
          onOwnedIngredientsChanged: _handleOwnedIngredientsChanged,
          onHomeSelected: _showHome,
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
  home,
  recommendations,
  ownedIngredients,
}
