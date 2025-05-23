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
  
  const TagList({
    super.key,
    required this.tags,
    this.onRemoveTag,
    this.isSmall = false,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final tagChips = tags.map((tag) => TagChip(
      tag: tag,
      onRemove: onRemoveTag != null ? () => onRemoveTag!(tag) : null,
      isSmall: isSmall,
    )).toList();

    if (isScrollable) {
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
