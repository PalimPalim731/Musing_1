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
  
  const TagChip({
    super.key, 
    required this.tag,
    this.onRemove,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = theme.colorScheme.primary;
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
                Text(
                  TextUtils.truncateWithEllipsis(tag.label, 7),
                  style: TextStyle(
                    color: tagColor.withOpacity(0.8),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
}