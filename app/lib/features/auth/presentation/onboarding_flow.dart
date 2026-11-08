import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../core/config/app_config.dart';
import '../../../core/telemetry/http_timing_interceptor.dart';
import '../../home/presentation/home_screen.dart';
import '../../ingredient/presentation/initial_ingredient_screen.dart';
import '../../ingredients/presentation/owned_ingredients_screen.dart';
import '../../recommendation/presentation/recommendation_screen.dart';
import '../../recipe/presentation/recipe_detail_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'onboarding_entry.dart';
import 'kakao_login_screen.dart';
import 'onboarding_motion_sequence.dart';
import 'terms_consent_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({this.onKakaoLogin, super.key});

  final VoidCallback? onKakaoLogin;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final ApiClient _apiClient;

  _OnboardingStage _stage = _OnboardingStage.splash;
  Set<String> _registeredIngredients = const {};
  bool _isLoggingIn = false;
  bool _hasLoginError = false;
  int _homeRevision = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(basePathOverride: AppConfig.apiBaseUrl);
    _apiClient.dio.interceptors.add(HttpTimingInterceptor(_apiClient.dio));
  }

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
      // New accounts are blocked by the backend terms-consent filter until
      // the consent screen completes. Do not query protected inventory before
      // routing them to that screen; otherwise login appears to fail with 403.
      if (!loginResponse.termsConsentRequired &&
          loginResponse.hasOwnedIngredients) {
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
        if (loginResponse.termsConsentRequired) {
          _stage = _OnboardingStage.terms;
        }
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

  Future<void> _acceptTerms() async {
    await _apiClient.getAuthApi().acceptTermsConsent(
      termsConsentRequest: TermsConsentRequest(
        (builder) => builder
          ..termsVersion = 'v1'
          ..privacyVersion = 'v1'
          ..age14OrOver = true,
      ),
    );
    if (mounted) setState(() => _stage = _OnboardingStage.ingredients);
  }

  Future<void> _completeV4Onboarding(Set<int> variantIds) async {
    await _apiClient.getOnboardingApi().completeOnboarding(
      onboardingRequest: OnboardingRequest(
        (builder) => builder.variantIds.addAll(variantIds),
      ),
    );
  }

  Future<void> _showRecipeDetail(int recipeId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            RecipeDetailScreen(apiClient: _apiClient, recipeId: recipeId),
      ),
    );
    if (mounted) setState(() => _homeRevision++);
  }

  void _showSettings() => setState(() => _stage = _OnboardingStage.settings);

  Future<void> _logout() async {
    try {
      await UserApi.instance.logout();
    } catch (_) {
      // A local session reset is still safe when the provider session has
      // already expired.
    }
    if (mounted) setState(() => _stage = _OnboardingStage.login);
  }

  Future<void> _deleteAccount() async {
    try {
      final response = await _apiClient.getAuthApi().deleteCurrentAccount();
      debugPrint(
        '[Account deletion] DELETE ${response.requestOptions.uri} '
        'status=${response.statusCode}',
      );
      _apiClient.removeBearerAuth('bearerAuth');
      try {
        await UserApi.instance.logout();
      } catch (_) {
        // The backend deletion already succeeded; an expired provider session
        // should not prevent the local account from being cleared.
      }
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[Account deletion] failed '
        'status=${error.response?.statusCode} '
        'uri=${error.requestOptions.uri} '
        'body=${error.response?.data}',
      );
      debugPrintStack(
        label: '[Account deletion] stack',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _accountDeleted() {
    if (mounted) setState(() => _stage = _OnboardingStage.login);
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
        _OnboardingStage.terms => TermsConsentScreen(
          key: const ValueKey(_OnboardingStage.terms),
          onAccepted: _acceptTerms,
        ),
        _OnboardingStage.ingredients => InitialIngredientScreen(
          key: const ValueKey(_OnboardingStage.ingredients),
          apiClient: _apiClient,
          onSubmit: _handleIngredientsSubmitted,
          onBatchSubmit: _completeV4Onboarding,
          onViewRecommendations: _showHome,
        ),
        _OnboardingStage.recommendations => RecommendationScreen(
          key: const ValueKey(_OnboardingStage.recommendations),
          apiClient: _apiClient,
          ownedIngredientCount: _registeredIngredients.length,
          onRegisterIngredients: _showOwnedIngredients,
          onHomeSelected: _showHome,
          onIngredientsSelected: _showOwnedIngredients,
          onSettingsSelected: _showSettings,
          onRecipeSelected: _showRecipeDetail,
        ),
        _OnboardingStage.home => HomeScreen(
          key: ValueKey('home-$_homeRevision'),
          apiClient: _apiClient,
          onHomeSelected: _showHome,
          onIngredientsSelected: _showOwnedIngredients,
          onRecommendationsSelected: _showRecommendations,
          onSettingsSelected: _showSettings,
          onRecipeSelected: _showRecipeDetail,
        ),
        _OnboardingStage.ownedIngredients => OwnedIngredientsScreen(
          key: const ValueKey(_OnboardingStage.ownedIngredients),
          apiClient: _apiClient,
          onRegisterIngredients: _showOwnedIngredients,
          onOwnedIngredientsChanged: _handleOwnedIngredientsChanged,
          onHomeSelected: _showHome,
          onRecommendationsSelected: _showRecommendations,
          onSettingsSelected: _showSettings,
        ),
        _OnboardingStage.settings => SettingsScreen(
          key: const ValueKey(_OnboardingStage.settings),
          onBack: _showHome,
          onLogout: _logout,
          onDeleteAccount: _deleteAccount,
          onAccountDeleted: _accountDeleted,
        ),
      },
    );
  }
}

enum _OnboardingStage {
  splash,
  login,
  terms,
  ingredients,
  home,
  recommendations,
  ownedIngredients,
  settings,
}
