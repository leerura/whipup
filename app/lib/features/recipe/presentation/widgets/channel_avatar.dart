import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Circular YouTube channel profile image. Falls back to the channel name's
/// first letter when there is no image or it fails to load (docs/v4/ux V4-J).
class ChannelAvatar extends StatelessWidget {
  const ChannelAvatar({
    required this.channelName,
    required this.thumbnailUrl,
    required this.size,
    required this.initialFontSize,
    super.key,
  });

  final String channelName;
  final String? thumbnailUrl;
  final double size;
  final double initialFontSize;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Text(
        channelName.isEmpty ? '' : String.fromCharCode(channelName.runes.first),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: initialFontSize,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
    final url = thumbnailUrl;
    if (url == null || url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

/// One-line channel credit under a recipe card title. Hidden without a name.
class RecipeChannelLabel extends StatelessWidget {
  const RecipeChannelLabel({
    required this.channelName,
    required this.thumbnailUrl,
    this.fontSize = 12,
    super.key,
  });

  final String? channelName;
  final String? thumbnailUrl;
  final double fontSize;

  static bool hasChannel(String? name) => name?.trim().isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final name = channelName?.trim() ?? '';
    if (name.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        ChannelAvatar(
          channelName: name,
          thumbnailUrl: thumbnailUrl,
          size: 14,
          initialFontSize: 8,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
