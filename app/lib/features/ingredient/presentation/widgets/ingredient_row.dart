import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme.dart';

class IngredientRow extends StatelessWidget {
  const IngredientRow({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String assetPath;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      label: label,
      child: InkWell(
        onTap: () => onChanged(!selected),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: selected,
                  onChanged: (value) => onChanged(value ?? false),
                  activeColor: AppColors.primary,
                  checkColor: AppColors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SvgPicture.asset(
                assetPath,
                width: 34,
                height: 34,
                semanticsLabel: '$label 썸네일',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: selected
                      ? Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                        )
                      : Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
