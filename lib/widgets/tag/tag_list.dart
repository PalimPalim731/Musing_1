// widgets/tag/tag_list.dart

import 'package:flutter/material.dart';
import '../../models/tag.dart';
import 'tag_chip.dart';

/// Displays a list of tags as chips, with support for separating quick-tags and regular-tags
class TagList extends StatelessWidget {
  final List<TagData> quickTags; // Rectangle-based tags (3 chars)
  final List<TagData> regularTags; // Sidebar tags (longer names)
  final Function(TagData)? onRemoveTag;
  final bool isSmall;
  final bool isDraggable; // New parameter to control drag behavior

  const TagList({
    super.key,
    this.quickTags = const [],
    this.regularTags = const [],
    this.onRemoveTag,
    this.isSmall = false,
    this.isDraggable = true, // Default to draggable for applied tags
  });

  // Legacy constructor for backward compatibility
  const TagList.legacy({
    super.key,
    required List<TagData> tags,
    this.onRemoveTag,
    this.isSmall = false,
    bool isScrollable = false,
    bool allowMultiRow = true,
    this.isDraggable = true,
  })  : quickTags = const [],
        regularTags = tags;

  @override
  Widget build(BuildContext context) {
    if (quickTags.isEmpty && regularTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick-tags row (rectangle-based tags)
        if (quickTags.isNotEmpty) ...[
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: quickTags
                .map((tag) => TagChip(
                      tag: tag,
                      onRemove:
                          onRemoveTag != null ? () => onRemoveTag!(tag) : null,
                      isSmall: isSmall,
                      isQuickTag: true, // Special styling for quick-tags
                      isDraggable: isDraggable, // Pass drag control
                    ))
                .toList(),
          ),

          // Add spacing between quick-tags and regular-tags if both exist
          if (regularTags.isNotEmpty) SizedBox(height: isSmall ? 6.0 : 8.0),
        ],

        // Regular-tags row(s) (sidebar tags)
        if (regularTags.isNotEmpty)
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: regularTags
                .map((tag) => TagChip(
                      tag: tag,
                      onRemove:
                          onRemoveTag != null ? () => onRemoveTag!(tag) : null,
                      isSmall: isSmall,
                      isQuickTag: false, // Regular styling
                      isDraggable: isDraggable, // Pass drag control
                    ))
                .toList(),
          ),
      ],
    );
  }
}
