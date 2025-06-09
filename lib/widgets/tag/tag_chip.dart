// widgets/tag/tag_chip.dart

import 'package:flutter/material.dart';
import '../../models/tag.dart';
import '../../config/constants/layout.dart';
import '../../utils/text_utils.dart';

/// Displays a tag as a chip, for showing applied tags on notes
class TagChip extends StatelessWidget {
  final TagData tag;
  final VoidCallback? onRemove; // Keep for internal drag functionality
  final bool isSmall;
  final bool isQuickTag; // Parameter to distinguish quick-tags
  final bool isDraggable; // Parameter to control drag behavior

  const TagChip({
    super.key,
    required this.tag,
    this.onRemove,
    this.isSmall = false,
    this.isQuickTag = false, // Default to regular tag
    this.isDraggable = true, // Default to draggable when applied to note
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use different colors for quick-tags vs regular-tags
    final tagColor = isQuickTag
        ? theme.colorScheme.secondary // Secondary color for quick-tags
        : theme.colorScheme.primary; // Primary color for regular tags

    final fontSize = isSmall ? 10.0 : 12.0;
    final horizontalPadding =
        isSmall ? 8.0 : 10.0; // Slightly more padding without 'x'
    final verticalPadding = isSmall ? 4.0 : 6.0;

    // If this tag is applied to a note and draggable, wrap it in Draggable
    if (onRemove != null && isDraggable) {
      return _buildDraggableTagChip(context, theme, tagColor, fontSize,
          horizontalPadding, verticalPadding);
    } else {
      return _buildStaticTagChip(context, theme, tagColor, fontSize,
          horizontalPadding, verticalPadding);
    }
  }

  Widget _buildDraggableTagChip(
    BuildContext context,
    ThemeData theme,
    Color tagColor,
    double fontSize,
    double horizontalPadding,
    double verticalPadding,
  ) {
    return Draggable<TagRemovalData>(
      // Pass tag removal data to identify which tag is being dragged for removal
      data: TagRemovalData(tag: tag, onRemove: onRemove!),

      // What appears during drag - slightly larger and more prominent
      feedback: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding + 2,
            vertical: verticalPadding + 1,
          ),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: tagColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: isQuickTag
              ? _buildQuickTagText(tag.label, Colors.white, fontSize + 1)
              : _buildRegularTagText(tag.label, Colors.white, fontSize + 1),
        ),
      ),

      // What remains in place during drag - reduced opacity
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTagChipContent(context, theme, tagColor, fontSize,
            horizontalPadding, verticalPadding),
      ),

      // Normal appearance when not dragging
      child: _buildTagChipContent(context, theme, tagColor, fontSize,
          horizontalPadding, verticalPadding),
    );
  }

  Widget _buildStaticTagChip(
    BuildContext context,
    ThemeData theme,
    Color tagColor,
    double fontSize,
    double horizontalPadding,
    double verticalPadding,
  ) {
    return _buildTagChipContent(
        context, theme, tagColor, fontSize, horizontalPadding, verticalPadding);
  }

  Widget _buildTagChipContent(
    BuildContext context,
    ThemeData theme,
    Color tagColor,
    double fontSize,
    double horizontalPadding,
    double verticalPadding,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 6.0, bottom: 6.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: tagColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: isQuickTag
              ? _buildQuickTagText(tag.label, tagColor, fontSize)
              : _buildRegularTagText(tag.label, tagColor, fontSize),
        ),
      ),
    );
  }

  /// Build text for quick-tags (rectangle-style with special formatting)
  Widget _buildQuickTagText(String text, Color color, double baseFontSize) {
    if (text.isEmpty) return const SizedBox.shrink();

    final smallFontSize = baseFontSize * 0.6;

    // First character (normal size, capitalized)
    final firstChar = text.isNotEmpty ? text[0].toUpperCase() : '';

    // Remaining characters (smaller size, stacked vertically)
    final remainingChars = text.length > 1 ? text.substring(1) : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // First character
        Text(
          firstChar,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: baseFontSize,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),

        // Remaining characters (stacked vertically if present)
        if (remainingChars.isNotEmpty) ...[
          const SizedBox(width: 1), // Small gap between first char and stack
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Second character
              if (remainingChars.isNotEmpty)
                Text(
                  remainingChars[0],
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),

              // Third character
              if (remainingChars.length > 1)
                Text(
                  remainingChars[1],
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build text for regular tags (normal text formatting)
  Widget _buildRegularTagText(String text, Color color, double fontSize) {
    return Text(
      TextUtils.truncateWithEllipsis(text, 10),
      style: TextStyle(
        color: color.withOpacity(0.8),
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Data class for tag removal during drag operations
class TagRemovalData extends Object {
  final TagData tag;
  final VoidCallback onRemove;

  const TagRemovalData({
    required this.tag,
    required this.onRemove,
  });
}
