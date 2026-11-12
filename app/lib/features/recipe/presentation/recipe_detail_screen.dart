import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../app/theme.dart';
import '../../ingredient/presentation/ingredient_presentation_catalog.dart';
import '../../ingredient/presentation/widgets/ingredient_thumbnail.dart';
import 'video_pip_geometry.dart';
import 'youtube_embed_request.dart';

// Coupang Partners is not enabled until the app is released.
const _coupangEnabled = false;

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    required this.apiClient,
    required this.recipeId,
    super.key,
  });

  final ApiClient apiClient;
  final int recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<RecipeDetailResponse> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _fetchRecipe();
  }

  Future<RecipeDetailResponse> _fetchRecipe() async {
    final response = await widget.apiClient.getRecipeApi().getRecipeDetail(
      recipeId: widget.recipeId,
    );
    final recipe = response.data;
    if (recipe == null) {
      throw StateError('The recipe detail response body is empty.');
    }

    return recipe;
  }

  void _retry() {
    setState(() => _recipeFuture = _fetchRecipe());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          '레시피',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      body: FutureBuilder<RecipeDetailResponse>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _RecipeDetailError(onRetry: _retry);
          }

          return _RecipeDetailContent(
            apiClient: widget.apiClient,
            recipe: snapshot.requireData,
            onChanged: _retry,
          );
        },
      ),
    );
  }
}

class _RecipeDetailContent extends StatefulWidget {
  const _RecipeDetailContent({
    required this.apiClient,
    required this.recipe,
    required this.onChanged,
  });

  final ApiClient apiClient;
  final RecipeDetailResponse recipe;
  final VoidCallback onChanged;

  @override
  State<_RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends State<_RecipeDetailContent> {
  final _scrollController = ScrollController();
  final _videoKey = GlobalKey();
  final _overlayKey = GlobalKey();
  WebViewController? _videoController;
  double _videoTop = 0;
  bool _isCollapsed = false;
  bool _videoUnavailable = false;

  RecipeDetailResponse get recipe => widget.recipe;
  bool _isInDailyMenu = false;
  bool _dailyMenuLoaded = false;
  bool _isSavingDailyMenu = false;

  @override
  void initState() {
    super.initState();
    _loadDailyMenuState();
  }

  Future<void> _loadDailyMenuState() async {
    try {
      final response = await widget.apiClient.getDailyMenuApi().getDailyMenu();
      final items = response.data?.items ?? const <RecommendationItem>[];
      if (!mounted) return;
      setState(() {
        _isInDailyMenu = items.any((item) => item.recipeId == recipe.recipeId);
        _dailyMenuLoaded = true;
      });
    } catch (error) {
      debugPrint('Today menu state unavailable: $error');
      if (mounted) setState(() => _dailyMenuLoaded = true);
    }
  }

  Future<void> _toggleDailyMenu() async {
    if (_isSavingDailyMenu) return;
    setState(() => _isSavingDailyMenu = true);
    try {
      if (_isInDailyMenu) {
        await widget.apiClient.getDailyMenuApi().removeDailyMenu(
          recipeId: recipe.recipeId,
        );
      } else {
        await widget.apiClient.getDailyMenuApi().addDailyMenu(
          dailyMenuRequest: DailyMenuRequest(
            (builder) => builder.recipeId = recipe.recipeId,
          ),
        );
      }
      if (!mounted) return;
      setState(() => _isInDailyMenu = !_isInDailyMenu);
    } catch (error) {
      debugPrint('Failed to update today menu: $error');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('잠시 후 다시 시도해 주세요.')));
      }
    } finally {
      if (mounted) setState(() => _isSavingDailyMenu = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_videoController == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _videoController == null) return;
      final videoContext = _videoKey.currentContext;
      final stackContext = _overlayKey.currentContext;
      if (videoContext == null ||
          stackContext == null ||
          !stackContext.mounted) {
        return;
      }
      final videoBox = videoContext.findRenderObject() as RenderBox?;
      final stackBox = stackContext.findRenderObject() as RenderBox?;
      if (videoBox == null || stackBox == null || !videoBox.hasSize) return;
      final stackTop = stackBox.localToGlobal(Offset.zero).dy;
      final videoPosition = videoBox.localToGlobal(Offset.zero).dy - stackTop;
      final collapsed = videoPosition <= 0;
      final top = videoPosition;
      if (top != _videoTop || collapsed != _isCollapsed) {
        setState(() {
          _videoTop = top;
          _isCollapsed = collapsed;
        });
      }
    });
  }

  Future<void> _startVideo() async {
    final videoId = _youtubeVideoId(recipe.shortsReference);
    if (videoId == null) return;
    final headers = YoutubeEmbedRequest.headersForPlatform(
      defaultTargetPlatform,
    );
    if (headers == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이 기기에서는 영상 재생을 지원하지 않아요.')));
      return;
    }
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    try {
      final controller = WebViewController.fromPlatformCreationParams(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black);
      if (controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
      await controller.loadRequest(
        YoutubeEmbedRequest.uriForVideo(videoId),
        headers: headers,
      );
      if (!mounted) return;
      setState(() {
        _videoController = controller;
        _videoUnavailable = false;
        _isCollapsed = false;
      });
    } catch (error) {
      debugPrint('Failed to start YouTube player: $error');
      if (!mounted) return;
      setState(() => _videoUnavailable = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상을 재생할 수 없어요. 원본 영상 링크를 확인해 주세요.')),
      );
      return;
    }
    _onScroll();
  }

  String? _youtubeVideoId(String reference) {
    final uri = Uri.tryParse(reference);
    if (uri == null) return null;
    if (uri.host == 'youtu.be' || uri.host == 'www.youtu.be') {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }
    if (uri.queryParameters['v']?.isNotEmpty == true) {
      return uri.queryParameters['v'];
    }
    final segments = uri.pathSegments;
    for (final marker in ['shorts', 'embed', 'live']) {
      final index = segments.indexOf(marker);
      if (index >= 0 && index + 1 < segments.length) {
        return segments[index + 1];
      }
    }
    return null;
  }

  Future<void> _openSource() async {
    final uri = Uri.tryParse(recipe.shortsReference);
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('원본 영상 링크를 확인할 수 없어요.')));
      return;
    }
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Failed to open source URL: $error\n$stackTrace');
      try {
        opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } on Object catch (fallbackError, fallbackStackTrace) {
        debugPrint(
          'Failed to open source URL with platform default: '
          '$fallbackError\n$fallbackStackTrace',
        );
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Failed to open source URL: $error\n$stackTrace');
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('원본 영상을 열 수 없어요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final availabilityMessage = recipe.missingCount == 0
        ? '지금 바로 만들 수 있어요'
        : '재료 ${recipe.missingCount}개가 부족해요';
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availablePipSize = VideoPipGeometry.sizeForAvailableWidth(
                constraints.maxWidth,
              );
              final showPip = _isCollapsed && availablePipSize != null;
              final pipSize = showPip ? availablePipSize : null;
              final hidePlayerForNarrowPip =
                  _isCollapsed && availablePipSize == null;

              return Stack(
                key: _overlayKey,
                clipBehavior: Clip.none,
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification ||
                          notification is ScrollEndNotification) {
                        _onScroll();
                      }
                      return false;
                    },
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        ClipRRect(
                          key: _videoKey,
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _videoController == null
                                ? _VideoThumbnail(
                                    thumbnailUrl: recipe.thumbnailUrl,
                                    hasVideo:
                                        _youtubeVideoId(
                                          recipe.shortsReference,
                                        ) !=
                                        null,
                                    onPlay: _startVideo,
                                    unavailable: _videoUnavailable,
                                  )
                                : const ColoredBox(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          recipe.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _VideoCredit(
                          channelName: recipe.sourceChannelName,
                          onTap: _openSource,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              recipe.missingCount == 0
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                              size: 19,
                              color: recipe.missingCount == 0
                                  ? const Color(0xFF2E8B57)
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                availabilityMessage,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 28),
                        _SectionTitle(
                          title: '필요한 재료',
                          count: recipe.requirements.length,
                        ),
                        const SizedBox(height: 14),
                        ...recipe.requirements.map(
                          (requirement) => _RequirementRow(
                            apiClient: widget.apiClient,
                            requirement: requirement,
                            onChanged: widget.onChanged,
                          ),
                        ),
                        if (recipe.optionalIngredients.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _SectionTitle(
                            title: '선택 재료',
                            count: recipe.optionalIngredients.length,
                          ),
                          const SizedBox(height: 14),
                          ...recipe.optionalIngredients.map(
                            (ingredient) =>
                                _OptionalIngredientRow(ingredient: ingredient),
                          ),
                        ],
                        const SizedBox(height: 28),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 28),
                        _SectionTitle(
                          title: '조리 순서',
                          count: recipe.steps.length,
                        ),
                        const SizedBox(height: 18),
                        ...recipe.steps.map(
                          (step) => _RecipeStepRow(step: step),
                        ),
                      ],
                    ),
                  ),
                  if (_videoController != null)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      top: showPip ? VideoPipGeometry.topInset : _videoTop,
                      left: showPip ? null : 20,
                      right: showPip ? VideoPipGeometry.rightInset : 20,
                      width: pipSize?.width,
                      height:
                          pipSize?.height ??
                          (constraints.maxWidth - 40) * 9 / 16,
                      child: Offstage(
                        offstage: hidePlayerForNarrowPip,
                        child: _ActiveVideoPlayer(
                          controller: _videoController!,
                          collapsed: showPip,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: ColoredBox(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _dailyMenuLoaded && !_isSavingDailyMenu
                      ? _toggleDailyMenu
                      : null,
                  icon: Icon(
                    _isInDailyMenu
                        ? Icons.check_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                  label: Text(
                    _isSavingDailyMenu
                        ? '저장 중...'
                        : _isInDailyMenu
                        ? '오늘 먹을 메뉴에서 빼기'
                        : '오늘 먹을 메뉴 담기',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isInDailyMenu
                        ? AppColors.errorSurface
                        : AppColors.primary,
                    foregroundColor: _isInDailyMenu
                        ? AppColors.primary
                        : AppColors.white,
                    disabledBackgroundColor: AppColors.disabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveVideoPlayer extends StatelessWidget {
  const _ActiveVideoPlayer({required this.controller, required this.collapsed});

  final WebViewController controller;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      elevation: collapsed ? 8 : 0,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(collapsed ? 0 : 8),
      child: WebViewWidget(controller: controller),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({
    required this.thumbnailUrl,
    required this.hasVideo,
    required this.onPlay,
    required this.unavailable,
  });

  final String thumbnailUrl;
  final bool hasVideo;
  final VoidCallback onPlay;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _RecipeImage(thumbnailUrl: thumbnailUrl),
        if (unavailable)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '영상을 재생할 수 없어요',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '원본 영상은 아래 링크에서 바로 볼 수 있어요',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (hasVideo)
          Center(
            child: IconButton.filled(
              tooltip: '유튜브 영상 재생',
              onPressed: onPlay,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.72),
                foregroundColor: Colors.white,
                minimumSize: const Size(64, 64),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 42),
            ),
          ),
      ],
    );
  }
}

class _VideoCredit extends StatelessWidget {
  const _VideoCredit({required this.channelName, required this.onTap});

  final String? channelName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = channelName?.trim().isNotEmpty == true
        ? channelName!.trim()
        : '원본 채널';
    final initial = String.fromCharCode(label.runes.first);
    return SizedBox(
      height: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF636366),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$label · YouTube Shorts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF636366),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '원본 보기',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.open_in_new_rounded,
                size: 12,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  const _RecipeImage({required this.thumbnailUrl});

  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl.isEmpty) {
      return const _RecipeImagePlaceholder();
    }

    return Image.network(
      thumbnailUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const _RecipeImagePlaceholder(),
    );
  }
}

class _RecipeImagePlaceholder extends StatelessWidget {
  const _RecipeImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceSubtle,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 48,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '$count',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _quantity(String? amount, String? unit) {
  return [amount, unit]
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' ');
}

String _withParticle(
  String text,
  String consonant,
  String vowel, {
  bool rieulAsVowel = false,
}) {
  if (text.isEmpty) return text;
  final last = text.runes.last;
  if (last < 0xAC00 || last > 0xD7A3) return '$text($consonant/$vowel)';
  final finalConsonant = (last - 0xAC00) % 28;
  final useVowel = finalConsonant == 0 || (rieulAsVowel && finalConsonant == 8);
  return '$text${useVowel ? vowel : consonant}';
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.apiClient,
    required this.requirement,
    required this.onChanged,
  });

  final ApiClient apiClient;
  final DetailRequirement requirement;
  final VoidCallback onChanged;

  Future<void> _addVariant(
    BuildContext context,
    IngredientVariantOption variant,
  ) async {
    try {
      await apiClient.getOwnedIngredientApi().addOwnedIngredient(
        addOwnedIngredientRequest: AddOwnedIngredientRequest(
          (builder) => builder.variantId = variant.variantId,
        ),
      );
      onChanged();
    } catch (error) {
      debugPrint('Failed to add recipe ingredient: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재료를 담지 못했어요. 다시 시도해 주세요.')),
        );
      }
    }
  }

  Future<void> _removeOwned(BuildContext context, String ownedName) async {
    final shouldRemove = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$ownedName을 다 먹었나요?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('확인하면 재료함에서도 삭제돼요.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: const Text('다 먹었어요'),
              ),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: const Text('아직 있어요'),
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldRemove != true || !context.mounted) return;

    try {
      final response = await apiClient
          .getOwnedIngredientApi()
          .getOwnedIngredients();
      final owned = response.data?.items
          .where((item) => item.name == ownedName)
          .toList(growable: false);
      if (owned == null || owned.isEmpty) return;
      await apiClient.getOwnedIngredientApi().deleteOwnedIngredient(
        userIngredientId: owned.first.userIngredientId,
      );
      onChanged();
    } catch (error) {
      debugPrint('Failed to remove recipe ingredient: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재료를 삭제하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    }
  }

  Future<void> _openCoupang(BuildContext context, String name) async {
    final last = name.runes.last;
    final particle =
        last >= 0xAC00 && last <= 0xD7A3 && (last - 0xAC00) % 28 == 0
        ? '를'
        : '을';
    final shouldOpen = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '쿠팡에서 $name$particle 찾아볼까요?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('쿠팡의 검색 결과를 외부에서 확인할 수 있어요.'),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('쿠팡으로 이동'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('취소'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldOpen != true || !context.mounted) return;
    final uri = Uri.https('www.coupang.com', '/np/search', {'q': name});
    var opened = false;
    try {
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to open Coupang as a Universal Link: $error\n$stackTrace',
      );
    }
    if (!opened) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (error, stackTrace) {
        debugPrint(
          'Failed to open Coupang in an external browser: $error\n$stackTrace',
        );
      }
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('쿠팡을 열 수 없어요.')));
    }
  }

  Future<void> _selectVariant(
    BuildContext context,
    DetailRequirementOption option,
  ) async {
    final variants = option.addableVariants;
    final selected = await showModalBottomSheet<IngredientVariantOption>(
      context: context,
      builder: (sheetContext) {
        var selected = variants.first;
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '어떤 재료가 있나요?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '이 레시피에 맞는 재료예요. 하나를 골라주세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        for (final variant in variants)
                          InkWell(
                            onTap: () =>
                                setSheetState(() => selected = variant),
                            child: SizedBox(
                              height: 44,
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Icon(
                                    selected == variant
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: selected == variant
                                        ? AppColors.primary
                                        : AppColors.border,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  IngredientThumbnail(
                                    displayName: variant.name,
                                    assetPath: ingredientAssetPathFor(
                                      variant.name,
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    variant.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text('${selected.name} 담기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null && context.mounted) {
      await _addVariant(context, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = requirement.oneOf.value;
    final List<DetailRequirementOption> options;
    final List<IngredientMatch> matches;
    final bool satisfied;
    if (value is SatisfiedDetailRequirement) {
      options = value.options.toList(growable: false);
      matches = value.matches.toList(growable: false);
      satisfied = true;
    } else if (value is MissingDetailRequirement) {
      options = value.options.toList(growable: false);
      matches = const [];
      satisfied = false;
    } else {
      throw StateError(
        'Unsupported detail requirement type: ${value.runtimeType}',
      );
    }

    final quantities = options
        .map((option) => _quantity(option.amount, option.unit))
        .toSet();
    final sharedQuantity = quantities.length == 1 ? quantities.single : '';
    final name = options
        .map((option) {
          final quantity = _quantity(option.amount, option.unit);
          return quantities.length > 1 && quantity.isNotEmpty
              ? '${option.displayName} $quantity'
              : option.displayName;
        })
        .join(' 또는 ');
    final notes = <String>{};
    if (satisfied) {
      for (final match in matches) {
        if (match.type == IngredientMatchTypeEnum.PREPARATION) {
          notes.add(
            '가지고 있는 ${_withParticle(match.ownedName, '을', '를')} 활용할 수 있어요',
          );
        } else if (match.type == IngredientMatchTypeEnum.SUBSTITUTE) {
          notes.add(
            '${_withParticle(match.requiredName, '은', '는')} 가지고 있는 ${_withParticle(match.ownedName, '으로', '로', rieulAsVowel: true)} 대신할 수 있어요',
          );
        } else if (match.requiredName != match.ownedName) {
          notes.add(
            '보유한 ${_withParticle(match.ownedName, '으로', '로', rieulAsVowel: true)} 만들 수 있어요',
          );
        } else if (options.length > 1) {
          notes.add(
            '가지고 있는 ${_withParticle(match.ownedName, '을', '를')} 사용할 수 있어요',
          );
        }
      }
    } else {
      notes.add(options.length > 1 ? '이 중 하나가 더 필요해요' : '이 재료가 더 필요해요');
      for (final option in options) {
        if (option.substitutes.isEmpty) continue;
        final substitutes = option.substitutes
            .map((substitute) {
              final quantity = _quantity(substitute.amount, substitute.unit);
              return quantity.isEmpty
                  ? substitute.displayName
                  : '${substitute.displayName} ($quantity)';
            })
            .join(' 또는 ');
        notes.add('${option.displayName}: $substitutes 대체 가능');
      }
    }

    final addable = options
        .where((option) => option.addableVariants.isNotEmpty)
        .toList();
    final actionCount = satisfied ? matches.length : addable.length;
    void performAction(int index) {
      if (satisfied) {
        _removeOwned(context, matches[index].ownedName);
      } else {
        _selectVariant(context, addable[index]);
      }
    }

    return Semantics(
      label: '${satisfied ? '충족' : '부족'}, $name',
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: actionCount == 1 ? () => performAction(0) : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    Icon(
                      satisfied
                          ? Icons.check_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: satisfied
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (sharedQuantity.isNotEmpty)
                      Text(
                        sharedQuantity,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: satisfied
                              ? AppColors.textMuted
                              : AppColors.primary,
                          letterSpacing: 0,
                        ),
                      ),
                    if (actionCount > 1)
                      PopupMenuButton<int>(
                        tooltip: satisfied ? '보유 재료 빼기' : '재료함에 담기',
                        onSelected: performAction,
                        itemBuilder: (context) => [
                          for (var i = 0; i < actionCount; i++)
                            PopupMenuItem(
                              value: i,
                              child: Text(
                                satisfied
                                    ? '${matches[i].ownedName} 빼기'
                                    : '${addable[i].displayName} 담기',
                              ),
                            ),
                        ],
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (notes.isNotEmpty || !satisfied)
              Padding(
                padding: const EdgeInsets.only(top: 1, bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final note in notes)
                            Text(
                              note,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: !satisfied && note == notes.first
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.4,
                                    letterSpacing: 0,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    if (_coupangEnabled && !satisfied && options.length == 1)
                      TextButton(
                        onPressed: () =>
                            _openCoupang(context, options.single.displayName),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          minimumSize: const Size(0, 28),
                          padding: const EdgeInsets.only(left: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '쿠팡에서 보기 ↗',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (_coupangEnabled && !satisfied && options.length > 1)
                      PopupMenuButton<int>(
                        tooltip: '쿠팡에서 보기',
                        onSelected: (index) =>
                            _openCoupang(context, options[index].displayName),
                        itemBuilder: (context) => [
                          for (var i = 0; i < options.length; i++)
                            PopupMenuItem(
                              value: i,
                              child: Text('${options[i].displayName} 쿠팡에서 보기'),
                            ),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                          child: Text(
                            '쿠팡에서 보기 ↗',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionalIngredientRow extends StatelessWidget {
  const _OptionalIngredientRow({required this.ingredient});

  final DetailIngredientDisplay ingredient;

  @override
  Widget build(BuildContext context) {
    final quantity = _quantity(ingredient.amount, ingredient.unit);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.radio_button_unchecked_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              ingredient.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
          ),
          if (quantity.isNotEmpty) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                quantity,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted, letterSpacing: 0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeStepRow extends StatelessWidget {
  const _RecipeStepRow({required this.step});

  final RecipeStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.errorSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${step.order}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                step.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeDetailError extends StatelessWidget {
  const _RecipeDetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 18),
            Text(
              '레시피를 불러오지 못했어요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
