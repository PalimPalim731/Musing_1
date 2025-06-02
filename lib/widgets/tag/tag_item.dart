// widgets/tag/tag_item.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../config/theme/app_theme.dart';
import '../../models/tag.dart';
import '../../services/tag_service.dart';
import '../../utils/text_utils.dart';

/// Individual tag item in the right sidebar with category-specific colors
class TagItem extends StatelessWidget {
  final double height;
  final VoidCallback? onTap;
  final TagData tag;
  final bool isCompact;

  const TagItem({
    super.key,
    required this.height,
    this.onTap,
    required this.tag,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = tag.isSelected;
    final radius = isCompact ? AppLayout.tagRadius * 0.8 : AppLayout.tagRadius;
    final fontSize =
        AppLayout.getFontSize(context, baseSize: isCompact ? 12.0 : 14.0);
    final borderWidth =
        isSelected ? (isCompact ? 1.2 : 1.5) : (isCompact ? 0.8 : 1.0);

    // Get category-specific color for this tag
    final tagService = TagService();
    final tagCategory = tagService.getTagCategory(tag.id);
    final tagColor = AppTheme.getCategoryColor(tagCategory);

    // Wrap with Draggable widget
    return Draggable<TagData>(
      // The data that will be passed to the DragTarget
      data: tag,
      // What is displayed as the dragged item during drag
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.9), // Use category color
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            TextUtils.truncateWithEllipsis(tag.label, 10),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Reduce the opacity of the original widget during drag
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTagItem(context, theme, isSelected, radius, fontSize,
            borderWidth, tagColor),
      ),
      // The actual widget displayed when not dragging
      child: _buildTagItem(
          context, theme, isSelected, radius, fontSize, borderWidth, tagColor),
    );
  }

  // Extracted the original tag item widget to reduce code duplication
  Widget _buildTagItem(BuildContext context, ThemeData theme, bool isSelected,
      double radius, double fontSize, double borderWidth, Color tagColor) {
    return Semantics(
      label: tag.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: isSelected
                ? tagColor.withOpacity(0.15)
                : tagColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: isSelected
                  ? tagColor.withOpacity(0.5)
                  : tagColor.withOpacity(0.15),
              width: borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              splashColor: tagColor.withOpacity(0.15),
              highlightColor: tagColor.withOpacity(0.1),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    TextUtils.truncateWithEllipsis(tag.label, 10),
                    style: TextStyle(
                      color: isSelected ? tagColor : tagColor.withOpacity(0.8),
                      fontSize: fontSize,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
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
