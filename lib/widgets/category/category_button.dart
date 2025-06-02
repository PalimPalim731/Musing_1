// widgets/category/category_button.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../config/theme/app_theme.dart';

/// Individual category button with category-specific colors
class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool
      isActiveForTags; // New parameter to indicate if this category's tags are active
  final VoidCallback onTap;
  final double height;
  final EdgeInsets? margin;
  final bool isCompact;

  const CategoryButton({
    super.key,
    required this.label,
    required this.isSelected,
    this.isActiveForTags = false, // Default to false
    required this.onTap,
    required this.height,
    this.margin,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius =
        isCompact ? AppLayout.buttonRadius * 0.7 : AppLayout.buttonRadius;
    final fontSize =
        AppLayout.getFontSize(context, baseSize: isCompact ? 14.0 : 16.0);

    // Get category-specific color
    final categoryColor = AppTheme.getCategoryColor(label);
    final categoryColorLight = AppTheme.getCategoryColorLight(label);

    // Determine the border based on whether this category's tags are active
    final borderWidth = isActiveForTags ? 3.0 : 0.0;
    final borderColor = isActiveForTags
        ? categoryColorLight // Use light variant for active tag category border
        : Colors.transparent;

    return Semantics(
      label: '$label category',
      selected: isSelected,
      button: true,
      child: Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: categoryColor, // Use category-specific color
          borderRadius: BorderRadius.circular(radius),
          boxShadow: AppTheme.getLightShadow(label), // Category-specific shadow
          // Add border to indicate active tag category
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  label,
                  style: AppTheme.categoryTextStyle.copyWith(
                    fontSize: fontSize,
                    // Make text bold if this category's tags are active
                    fontWeight:
                        isActiveForTags ? FontWeight.bold : FontWeight.w500,
                    color: Colors.white, // Keep text white for readability
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
