import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme.dart';

class IngredientSearchField extends StatelessWidget {
  const IngredientSearchField({
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.searchBorder),
    );

    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppColors.primary,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          hintText: '재료명을 검색하세요',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.placeholder,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 53,
            minHeight: 24,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 13, right: 16),
            child: SvgPicture.asset(
              'assets/ingredient/search.svg',
              width: 24,
              height: 24,
              semanticsLabel: '검색',
            ),
          ),
          suffixIconConstraints: const BoxConstraints.tightFor(
            width: 48,
            height: 50,
          ),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  onPressed: onClear,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  tooltip: '검색어 지우기',
                  icon: SvgPicture.asset(
                    'assets/ingredient/search_clear.svg',
                    width: 22,
                    height: 22,
                  ),
                ),
          contentPadding: EdgeInsets.only(right: onClear == null ? 13 : 0),
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
