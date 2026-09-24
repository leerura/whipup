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
            Text(
              availabilityMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 28),
        _SectionTitle(title: '필요한 재료', count: recipe.ingredients.length),
        const SizedBox(height: 14),
        ...recipe.ingredients.map(
          (ingredient) => _IngredientRow(ingredient: ingredient),
        ),
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

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final RecipeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final quantity = [
      ingredient.amount,
      ingredient.unit,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            ingredient.owned
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 21,
            color: ingredient.owned
                ? const Color(0xFF2E8B57)
                : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (quantity.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              quantity,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(width: 12),
          Text(
            ingredient.owned ? '보유' : '부족',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ingredient.owned
                  ? const Color(0xFF2E8B57)
                  : AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
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
