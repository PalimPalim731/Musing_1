// widgets/quick_tag/quick_tag_chip.dart

import 'package:flutter/material.dart';
import '../../models/quick_tag.dart';
import '../../config/constants/layout.dart';

/// Displays a quick tag as a chip, for showing applied quick tags on notes
/// Note: This component is legacy - the unified TagChip should be used instead
class QuickTagChip extends StatelessWidget {
  final QuickTagData quickTag;
  final VoidCallback? onRemove; // Keep for backward compatibility
  final bool isSmall;

  const QuickTagChip({
    super.key,
    required this.quickTag,
    this.onRemove,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = theme.colorScheme
        .secondary; // Use secondary color to differentiate from regular tags
    final fontSize = isSmall ? 10.0 : 12.0;
    final horizontalPadding = isSmall ? 8.0 : 10.0; // More padding without 'x'
    final verticalPadding = isSmall ? 4.0 : 6.0;

    return Container(
      margin: const EdgeInsets.only(right: 6.0, bottom: 6.0),
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
        child: _buildFormattedText(quickTag.label, tagColor, fontSize),
      ),
    );
  }

  Widget _buildFormattedText(String text, Color color, double baseFontSize) {
    if (text.isEmpty) return const SizedBox.shrink();

    final smallFontSize = baseFontSize * 0.6;

    // First character (normal size, capitalized)
    final firstChar = text[0].toUpperCase();

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
}
