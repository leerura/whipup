import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';

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
    final response = await widget.apiClient
        .getRecipeApi()
        .getRecipeDetail(recipeId: widget.recipeId);
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

          return _RecipeDetailContent(recipe: snapshot.requireData);
        },
      ),
    );
  }
}

class _RecipeDetailContent extends StatelessWidget {
  const _RecipeDetailContent({required this.recipe});

  final RecipeDetailResponse recipe;

  @override
  Widget build(BuildContext context) {
    final availabilityMessage = recipe.missingCount == 0
        ? '지금 바로 만들 수 있어요'
        : '재료 ${recipe.missingCount}개가 부족해요';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _RecipeImage(thumbnailUrl: recipe.thumbnailUrl),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          recipe.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
        _SectionTitle(title: '필요한 재료', count: recipe.requirements.length),
        const SizedBox(height: 14),
        ...recipe.requirements.map(
          (requirement) => _RequirementRow(requirement: requirement),
        ),
        if (recipe.optionalIngredients.isNotEmpty) ...[
          const SizedBox(height: 28),
          _SectionTitle(title: '선택 재료', count: recipe.optionalIngredients.length),
          const SizedBox(height: 14),
          ...recipe.optionalIngredients.map(
            (ingredient) => _OptionalIngredientRow(ingredient: ingredient),
          ),
        ],
        const SizedBox(height: 28),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 28),
        _SectionTitle(title: '조리 순서', count: recipe.steps.length),
        const SizedBox(height: 18),
        ...recipe.steps.map((step) => _RecipeStepRow(step: step)),
      ],
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
  const _RequirementRow({required this.requirement});

  final DetailRequirement requirement;

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
      throw StateError('Unsupported detail requirement type: ${value.runtimeType}');
    }

    final quantities = options.map((option) => _quantity(option.amount, option.unit)).toSet();
    final sharedQuantity = quantities.length == 1 ? quantities.single : '';
    final name = options.map((option) {
      final quantity = _quantity(option.amount, option.unit);
      return quantities.length > 1 && quantity.isNotEmpty
          ? '${option.displayName} $quantity'
          : option.displayName;
    }).join(' 또는 ');
    final notes = <String>{};
    if (satisfied) {
      for (final match in matches) {
        if (match.type == IngredientMatchTypeEnum.PREPARATION) {
          notes.add('가지고 있는 ${_withParticle(match.ownedName, '을', '를')} 활용할 수 있어요');
        } else if (match.type == IngredientMatchTypeEnum.SUBSTITUTE) {
          notes.add('${_withParticle(match.requiredName, '은', '는')} 가지고 있는 ${_withParticle(match.ownedName, '으로', '로', rieulAsVowel: true)} 대신할 수 있어요');
        } else if (options.length > 1) {
          notes.add('가지고 있는 ${_withParticle(match.ownedName, '을', '를')} 사용할 수 있어요');
        }
      }
    } else {
      notes.add(options.length > 1 ? '이 중 하나가 더 필요해요' : '이 재료가 더 필요해요');
      for (final option in options) {
        if (option.substitutes.isEmpty) continue;
        final substitutes = option.substitutes.map((substitute) {
          final quantity = _quantity(substitute.amount, substitute.unit);
          return quantity.isEmpty
              ? substitute.displayName
              : '${substitute.displayName} ($quantity)';
        }).join(' 또는 ');
        notes.add('${option.displayName}: $substitutes 대체 가능');
      }
    }

    return Semantics(
      label: '${satisfied ? '충족' : '부족'}, $name',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  satisfied ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: satisfied ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
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
                if (sharedQuantity.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      sharedQuantity,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: satisfied ? AppColors.textMuted : AppColors.primary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            for (final note in notes) ...[
              const SizedBox(height: 6),
              Text(
                note,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: !satisfied && note == notes.first
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
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
          const Icon(Icons.radio_button_unchecked_rounded,
            size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              ingredient.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14, color: AppColors.textPrimary, letterSpacing: 0,
              ),
            ),
          ),
          if (quantity.isNotEmpty) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                quantity,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted, letterSpacing: 0,
                ),
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
