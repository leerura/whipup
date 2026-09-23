import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme.dart';

class IngredientChip extends StatelessWidget {
  const IngredientChip({
    required this.label,
    this.onRemoved,
    super.key,
  });

  final String label;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final isSelected = onRemoved != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFFC7C7CC) : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 5, isSelected ? 6 : 12, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? const Color(0xFF3A3A3C)
                    : AppColors.chipText,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Semantics(
                button: true,
                label: '$label 제거',
                child: InkResponse(
                  onTap: onRemoved,
                  radius: 12,
                  child: SvgPicture.asset(
                    'assets/ingredient/remove.svg',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
