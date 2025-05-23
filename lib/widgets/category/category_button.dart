// widgets/category/category_button.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../config/theme/app_theme.dart';

/// Individual category button
class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;
  final EdgeInsets? margin;
  final bool isCompact;

  const CategoryButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.height,
    this.margin,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = isCompact ? AppLayout.buttonRadius * 0.7 : AppLayout.buttonRadius;
    final fontSize = AppLayout.getFontSize(context, 
        baseSize: isCompact ? 14.0 : 16.0);

    return Semantics(
      label: '$label category',
      selected: isSelected,
      button: true,
      child: Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: AppTheme.lightShadow,
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
                  style: AppTheme.categoryTextStyle.copyWith(fontSize: fontSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}