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
  final bool isDraggable; // Parameter to control drag behavior

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
        // Quick-tags row (rectangle-based tags) with reduced spacing
        if (quickTags.isNotEmpty) ...[
          Wrap(
            spacing: 2.0, // Reduced from 4.0 to 2.0 (50% reduction)
            runSpacing: 4.0, // Keep vertical spacing the same
            children: quickTags
                .map((tag) => TagChip(
                      tag: tag,
                      onRemove: onRemoveTag != null
                          ? () => onRemoveTag!(tag)
                          : null, // Internal callback for drag functionality
                      isSmall: isSmall,
                      isQuickTag: true, // Special styling for quick-tags
                      isDraggable: isDraggable, // Pass drag control
                    ))
                .toList(),
          ),

          // Add spacing between quick-tags and regular-tags if both exist (reduced by 50%)
          if (regularTags.isNotEmpty) SizedBox(height: isSmall ? 3.0 : 4.0),
        ],

        // Regular-tags row(s) (sidebar tags) with normal spacing
        if (regularTags.isNotEmpty)
          Wrap(
            spacing: 4.0, // Keep normal spacing for regular tags
            runSpacing: 4.0,
            children: regularTags
                .map((tag) => TagChip(
                      tag: tag,
                      onRemove: onRemoveTag != null
                          ? () => onRemoveTag!(tag)
                          : null, // Internal callback for drag functionality
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
