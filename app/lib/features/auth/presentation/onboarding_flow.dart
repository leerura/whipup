import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_token_store.dart';
import '../../../core/config/app_config.dart';
import '../../../core/telemetry/http_timing_interceptor.dart';
import '../../home/presentation/home_screen.dart';
import '../../ingredient/presentation/initial_ingredient_screen.dart';
import '../../ingredients/presentation/owned_ingredients_screen.dart';
import '../../recommendation/presentation/recommendation_screen.dart';
import '../../recipe/presentation/recipe_detail_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'onboarding_entry.dart';
import 'connection_error_screen.dart';
import 'onboarding_motion_sequence.dart';
import 'terms_consent_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

/// What the start flow needs to know to pick the first screen.
class _AccountSnapshot {
  const _AccountSnapshot({
    required this.termsConsentRequired,
    required this.onboardingCompleted,
    required this.hasOwnedIngredients,
  });

  final bool termsConsentRequired;
  final bool onboardingCompleted;
  final bool hasOwnedIngredients;
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final ApiClient _apiClient;
  final _tokenStore = AuthTokenStore();
  late final Future<_AccountSnapshot> _session;

  _OnboardingStage _stage = _OnboardingStage.splash;
  Set<String> _registeredIngredients = const {};
  bool _isRetrying = false;
  int _homeRevision = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(basePathOverride: AppConfig.apiBaseUrl);
    _apiClient.dio.interceptors.add(HttpTimingInterceptor(_apiClient.dio));
    // The start motion always plays; the account is prepared meanwhile.
    _session = _startSession();
  }

  /// Reuses the saved account, or creates a guest account when there is none.
  /// A 401 means the saved token is no longer valid, so it is dropped and a
  /// new guest account replaces it. Any other failure keeps the token and is
  /// reported to the caller so the user can retry.
  Future<_AccountSnapshot> _startSession() async {
    final token = await _tokenStore.read();
    if (token != null) {
      _apiClient.setBearerAuth('bearerAuth', token);
      try {
        final response = await _apiClient.getAuthApi().getCurrentAccount();
        final account = response.data;
        if (account == null) {
          throw StateError('The account response is empty.');
        }
        return _AccountSnapshot(
          termsConsentRequired: account.termsConsentRequired,
          onboardingCompleted: account.onboardingCompleted,
          hasOwnedIngredients: account.hasOwnedIngredients,
        );
      } on DioException catch (error) {
        _apiClient.removeBearerAuth('bearerAuth');
        if (error.response?.statusCode != 401) rethrow;
        await _tokenStore.delete();
      }
    }
    return _createGuest();
  }

  Future<_AccountSnapshot> _createGuest() async {
    final response = await _apiClient.getAuthApi().startGuestSession();
    final login = response.data;
    if (login == null) throw StateError('The guest response is empty.');

    _apiClient.setBearerAuth('bearerAuth', login.accessToken);
    await _tokenStore.write(login.accessToken);
    return _AccountSnapshot(
      termsConsentRequired: login.termsConsentRequired,
      onboardingCompleted: login.onboardingCompleted,
      hasOwnedIngredients: login.hasOwnedIngredients,
    );
  }

  Future<void> _finishOnboardingMotion() => _enterApp(_session);

  Future<void> _retryStart() async {
    setState(() => _isRetrying = true);
    await _enterApp(_startSession());
    if (mounted) setState(() => _isRetrying = false);
  }

  /// Routes to the first screen for the prepared account. Failures show the
  /// connection error screen instead of leaving the user on a blank motion.
  Future<void> _enterApp(Future<_AccountSnapshot> session) async {
    try {
      final account = await session;
      if (!mounted) return;
      await _routeTo(account);
    } catch (error, stackTrace) {
      debugPrint('[Start] failed: $error');
      debugPrintStack(label: '[Start] stack', stackTrace: stackTrace);
      if (mounted) setState(() => _stage = _OnboardingStage.connectionError);
    }
  }

  Future<void> _routeTo(_AccountSnapshot account) async {
    Set<String> registeredIngredients = const {};
    // New accounts are blocked by the backend terms-consent filter until
    // the consent screen completes, so inventory is not read before that.
    if (!account.termsConsentRequired && account.hasOwnedIngredients) {
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

    if (!mounted) return;

    setState(() {
      _registeredIngredients = Set<String>.unmodifiable(registeredIngredients);
      _stage = switch (onboardingEntryFor(
        onboardingCompleted: account.onboardingCompleted,
      )) {
        OnboardingEntry.initialIngredientRegistration =>
          _OnboardingStage.ingredients,
        OnboardingEntry.home => _OnboardingStage.home,
      };
      if (account.termsConsentRequired) {
        _stage = _OnboardingStage.terms;
      }
    });
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

  Future<void> _deleteAccount() async {
    try {
      final response = await _apiClient.getAuthApi().deleteCurrentAccount();
      debugPrint(
        '[Account deletion] DELETE ${response.requestOptions.uri} '
        'status=${response.statusCode}',
      );
      _apiClient.removeBearerAuth('bearerAuth');
      await _tokenStore.delete();
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

  /// A deleted account is replaced by a new guest account, starting again
  /// from the terms screen.
  void _accountDeleted() => _enterApp(_startSession());

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: switch (_stage) {
        _OnboardingStage.splash => OnboardingMotionSequence(
          key: const ValueKey(_OnboardingStage.splash),
          onCompleted: _finishOnboardingMotion,
        ),
        _OnboardingStage.connectionError => ConnectionErrorScreen(
          key: const ValueKey(_OnboardingStage.connectionError),
          isRetrying: _isRetrying,
          onRetry: _retryStart,
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
          onDeleteAccount: _deleteAccount,
          onAccountDeleted: _accountDeleted,
        ),
      },
    );
  }
}

enum _OnboardingStage {
  splash,
  connectionError,
  terms,
  ingredients,
  home,
  recommendations,
  ownedIngredients,
  settings,
}
