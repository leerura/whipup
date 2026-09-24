import 'package:flutter/material.dart';

class IngredientThumbnail extends StatelessWidget {
  const IngredientThumbnail({
    required this.displayName,
    required this.assetPath,
    this.size = 34,
    super.key,
  });

  final String displayName;
  final String? assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = _IngredientTextFallback(
      displayName: displayName,
      size: size,
    );
    final path = assetPath;
    if (path == null) return fallback;

    return Semantics(
      image: true,
      label: '$displayName 썸네일',
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _IngredientTextFallback extends StatelessWidget {
  const _IngredientTextFallback({
    required this.displayName,
    required this.size,
  });

  final String displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayName.isEmpty ? '?' : displayName.substring(0, 1),
        style: TextStyle(
          color: const Color(0xFFB87428),
          fontSize: size * 0.35,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
