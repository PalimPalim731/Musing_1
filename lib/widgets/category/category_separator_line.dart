// widgets/category/category_separator_line.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Visual separator line between category sidebar and note content area
/// Indicates where notes should be dragged for automatic categorization
class CategorySeparatorLine extends StatelessWidget {
  final double spacing;
  final double maxHeight;
  final bool isCompact;

  const CategorySeparatorLine({
    super.key,
    required this.spacing,
    required this.maxHeight,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: spacing * 2, // Double the normal spacing width
      child: LayoutBuilder(
        builder: (context, separatorConstraints) {
          // Calculate the exact positioning to match category buttons
          final topOffset = AppLayout.selectorHeight + (AppLayout.spacingS * 2);
          final bottomOffset = AppLayout.spacingS;
          final lineHeight = maxHeight - topOffset - bottomOffset;

          return Container(
            padding: EdgeInsets.only(top: topOffset, bottom: bottomOffset),
            child: Align(
              alignment: Alignment(0.7, 0),
              child: Container(
                width: 2.5, // Distinctive thickness
                height: lineHeight,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? theme.colorScheme.primary.withOpacity(0.6)
                      : theme.colorScheme.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(1.25),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
