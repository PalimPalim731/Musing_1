// widgets/tag/tag_chip.dart

import 'package:flutter/material.dart';
import '../../models/tag.dart';
import '../../config/constants/layout.dart';
import '../../utils/text_utils.dart';

/// Displays a tag as a chip, for showing applied tags on notes
class TagChip extends StatelessWidget {
  final TagData tag;
  final VoidCallback? onRemove;
  final bool isSmall;
  final bool isQuickTag; // New parameter to distinguish quick-tags

  const TagChip({
    super.key,
    required this.tag,
    this.onRemove,
    this.isSmall = false,
    this.isQuickTag = false, // Default to regular tag
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use different colors for quick-tags vs regular-tags
    final tagColor = isQuickTag
        ? theme.colorScheme.secondary // Secondary color for quick-tags
        : theme.colorScheme.primary; // Primary color for regular tags

    final fontSize = isSmall ? 10.0 : 12.0;
    final horizontalPadding = isSmall ? 6.0 : 8.0;
    final verticalPadding = isSmall ? 4.0 : 6.0;
    final iconSize = isSmall ? 14.0 : 16.0;

    return Container(
      margin: const EdgeInsets.only(right: 6.0, bottom: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onRemove,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the tag text with special formatting for quick-tags
                isQuickTag
                    ? _buildQuickTagText(tag.label, tagColor, fontSize)
                    : _buildRegularTagText(tag.label, tagColor, fontSize),

                if (onRemove != null) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onRemove,
                    child: Icon(
                      Icons.close,
                      size: iconSize,
                      color: tagColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
