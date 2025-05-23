// widgets/category/category_sidebar.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../services/category_service.dart';
import 'category_button.dart';

/// Left sidebar widget displaying category options
class CategorySidebar extends StatefulWidget {
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
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  final CategoryService _categoryService = CategoryService();
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _categoryService.getAllCategories();

    // Listen to category changes
    _categoryService.categoriesStream.listen((updatedCategories) {
      setState(() {
        _categories = updatedCategories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the offsets for proper alignment with content
    final topOffset =
        AppLayout.spacingS + AppLayout.selectorHeight + AppLayout.spacingS;
    final bottomOffset = AppLayout.spacingS;
    final sidebarWidth =
        AppLayout.getSidebarWidth(context, isCompact: widget.isCompact);

    return SizedBox(
      width: sidebarWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight =
              constraints.maxHeight - topOffset - bottomOffset;

          // Calculate button height for 3 categories with spacing between them
          final numberOfCategories = _categories.length;
          final totalSpacing = (numberOfCategories - 1) * AppLayout.spacingS;
          final buttonHeight =
              (availableHeight - totalSpacing) / numberOfCategories;

          return Container(
            padding: EdgeInsets.only(top: topOffset, bottom: bottomOffset),
            child: Column(
              children: [
                // Generate category buttons dynamically
                for (int i = 0; i < _categories.length; i++) ...[
                  CategoryButton(
                    label: _categories[i],
                    isSelected: widget.selectedCategory == _categories[i],
                    onTap: () => widget.onCategorySelected(_categories[i]),
                    height: buttonHeight,
                    isCompact: widget.isCompact,
                  ),

                  // Add spacing between buttons (except after the last one)
                  if (i < _categories.length - 1)
                    SizedBox(height: AppLayout.spacingS),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
