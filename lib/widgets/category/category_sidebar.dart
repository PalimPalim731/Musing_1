// widgets/category/category_sidebar.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import 'category_button.dart';

/// Left sidebar widget displaying category options
class CategorySidebar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final double screenHeight;
  final bool isCompact;

  const CategorySidebar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.screenHeight,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the offsets for proper alignment with content
    final topOffset = AppLayout.spacingS + AppLayout.selectorHeight + AppLayout.spacingS;
    final bottomOffset = AppLayout.spacingS;
    final sidebarWidth = AppLayout.getSidebarWidth(context, isCompact: isCompact);

    return SizedBox(
      width: sidebarWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight - topOffset - bottomOffset;
          final buttonHeight = (availableHeight - AppLayout.spacingS) / 2;

          return Container(
            padding: EdgeInsets.only(top: topOffset, bottom: bottomOffset),
            child: Column(
              children: [
                // Private button
                CategoryButton(
                  label: 'Private',
                  isSelected: selectedCategory == 'Private',
                  onTap: () => onCategorySelected('Private'),
                  height: buttonHeight,
                  isCompact: isCompact,
                ),

                // Spacer to push buttons to top and bottom
                const Spacer(),

                // Public button
                CategoryButton(
                  label: 'Public',
                  isSelected: selectedCategory == 'Public',
                  onTap: () => onCategorySelected('Public'),
                  height: buttonHeight,
                  isCompact: isCompact,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}