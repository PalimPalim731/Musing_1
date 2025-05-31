// widgets/tag/tag_list.dart

import 'package:flutter/material.dart';
import '../../models/tag.dart';
import 'tag_chip.dart';

/// Displays a list of tags as chips, used at the bottom of notes
class TagList extends StatelessWidget {
  final List<TagData> tags;
  final Function(TagData)? onRemoveTag;
  final bool isSmall;
  final bool isScrollable;
  final bool allowMultiRow; // New parameter to control wrapping behavior

  const TagList({
    super.key,
    required this.tags,
    this.onRemoveTag,
    this.isSmall = false,
    this.isScrollable = false,
    this.allowMultiRow = true, // Default to true for better UX
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final tagChips = tags
        .map((tag) => TagChip(
              tag: tag,
              onRemove: onRemoveTag != null ? () => onRemoveTag!(tag) : null,
              isSmall: isSmall,
            ))
        .toList();

    // If we want multi-row behavior (which is better for mobile)
    if (allowMultiRow) {
      return Wrap(
        spacing: 4.0, // Horizontal spacing between chips
        runSpacing: 4.0, // Vertical spacing between rows
        children: tagChips,
      );
    }
    // Legacy behavior - horizontal scrolling or simple wrap
    else if (isScrollable) {
      return SizedBox(
        height: isSmall ? 28.0 : 36.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: tagChips,
        ),
      );
    } else {
      return Wrap(
        children: tagChips,
      );
    }
  }
}
