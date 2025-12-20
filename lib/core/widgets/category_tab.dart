import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoryTab extends StatelessWidget {
  const CategoryTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.categorySelected
              : AppColors.categoryUnselected,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border(
            top: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.categoryBorder,
              width: 2,
            ),
            left: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.categoryBorder,
              width: 2,
            ),
            right: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.categoryBorder,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 17,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
