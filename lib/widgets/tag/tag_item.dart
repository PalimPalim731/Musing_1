// widgets/tag/tag_item.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';

/// Individual tag item in the right sidebar
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
    final fontSize = AppLayout.getFontSize(context, 
        baseSize: isCompact ? 12.0 : 14.0);
    final borderWidth = isSelected 
        ? (isCompact ? 1.2 : 1.5)
        : (isCompact ? 0.8 : 1.0);

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
            color: theme.colorScheme.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            tag.label,
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
        child: _buildTagItem(context, theme, isSelected, radius, fontSize, borderWidth),
      ),
      // The actual widget displayed when not dragging
      child: _buildTagItem(context, theme, isSelected, radius, fontSize, borderWidth),
    );
  }

  // Extracted the original tag item widget to reduce code duplication
  Widget _buildTagItem(BuildContext context, ThemeData theme, bool isSelected, 
      double radius, double fontSize, double borderWidth) {
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
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.colorScheme.primary.withOpacity(0.05),
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
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.colorScheme.primary.withOpacity(0.15),
              width: borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              splashColor: theme.colorScheme.primary.withOpacity(0.15),
              highlightColor: theme.colorScheme.primary.withOpacity(0.1),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    tag.label,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.8),
                      fontSize: fontSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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