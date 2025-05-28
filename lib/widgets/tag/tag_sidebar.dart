// widgets/tag/tag_sidebar.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../../services/tag_service.dart';
import 'editable_tag_item.dart';

/// Right sidebar with tags
class TagSidebar extends StatefulWidget {
  final double screenHeight;
  final bool isCompact;
  final Function(String, bool)? onTagSelected;

  const TagSidebar({
    super.key,
    required this.screenHeight,
    this.isCompact = false,
    this.onTagSelected,
  });

  @override
  State<TagSidebar> createState() => _TagSidebarState();
}

class _TagSidebarState extends State<TagSidebar> {
  final TagService _tagService = TagService();
  late List<TagData> _tags;

  @override
  void initState() {
    super.initState();
    _tags = _tagService.getAllTags();
    // Listen to tag changes (like renames)
    _tagService.tagsStream.listen((updatedTags) {
      setState(() {
        _tags = updatedTags;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add topOffset to align with note container top (after the empty space)
    final topOffset = AppLayout.selectorHeight + (AppLayout.spacingS * 2);
    final bottomOffset = AppLayout.spacingS;
    final sidebarWidth =
        AppLayout.getSidebarWidth(context, isCompact: widget.isCompact);

    return Container(
      width: sidebarWidth,
      margin: EdgeInsets.only(
        right: widget.isCompact ? AppLayout.spacingS * 0.5 : AppLayout.spacingS,
      ),
      // Use LayoutBuilder to get the exact height constraints
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height after accounting for top and bottom offsets
          final availableHeight =
              constraints.maxHeight - topOffset - bottomOffset;

          // Calculate tag height with same spacing logic as category buttons
          final totalItems = _tags.length;
          final totalSpacing =
              (totalItems - 1) * AppLayout.spacingS; // Same as category buttons

          // Distribute remaining height equally among tags - much larger tags now
          final tagHeight = (availableHeight - totalSpacing) / totalItems;
          final spacerHeight =
              AppLayout.spacingS; // Consistent with category button spacing

          return Container(
            padding: EdgeInsets.only(top: topOffset, bottom: bottomOffset),
            child: Column(
              children: List.generate(totalItems * 2 - 1, (index) {
                // Even indices are tags, odd indices are spacers
                if (index.isEven) {
                  final tagIndex = index ~/ 2;
                  return EditableTagItem(
                    height: tagHeight,
                    tag: _tags[tagIndex],
                    onTap: () => _handleTagTap(_tags[tagIndex]),
                    onRename: (newLabel) =>
                        _handleTagRename(_tags[tagIndex], newLabel),
                    isCompact: widget.isCompact,
                  );
                } else {
                  return SizedBox(height: spacerHeight);
                }
              }),
            ),
          );
        },
      ),
    );
  }

  void _handleTagTap(TagData tag) {
    widget.onTagSelected?.call(tag.id, !tag.isSelected);
  }

  void _handleTagRename(TagData tag, String newLabel) {
    _tagService.updateTag(tag.id, newLabel).then((updatedTag) {
      if (updatedTag != null) {
        // Service will broadcast changes to its stream,
        // which we're already listening to in initState
        debugPrint('Tag renamed: ${tag.label} → $newLabel');
      }
    });
  }
}
