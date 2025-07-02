// widgets/note/note_content.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import 'note_input_area.dart';
import '../rectangle/rectangle_bar.dart';

/// Main content area with note input and rectangle bar
class NoteContent extends StatelessWidget {
  final TextEditingController headerController;
  final TextEditingController noteController;
  final FocusNode? headerFocusNode;
  final FocusNode? noteFocusNode;
  final List<TagData> appliedQuickTags; // Rectangle-based tags (3 chars)
  final List<TagData> appliedRegularTags; // Sidebar tags (longer names)
  final Function(TagData)? onTagAdded;
  final Function(TagData)? onTagRemoved;
  final String selectedCategory; // Add category parameter

  // Action callbacks
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;
  final VoidCallback? onFormat;
  final VoidCallback? onCamera;
  final VoidCallback? onMic;
  final VoidCallback? onLink;

  const NoteContent({
    super.key,
    required this.headerController,
    required this.noteController,
    this.headerFocusNode,
    this.noteFocusNode,
    this.appliedQuickTags = const [],
    this.appliedRegularTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    required this.selectedCategory, // Add required category parameter
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  });

  // Legacy constructor for backward compatibility
  const NoteContent.legacy({
    super.key,
    required TextEditingController noteController,
    FocusNode? focusNode,
    List<TagData> appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.selectedCategory = 'Private', // Default category for legacy
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  })  : headerController = noteController,
        noteController = noteController,
        headerFocusNode = focusNode,
        noteFocusNode = null,
        appliedQuickTags = const [],
        appliedRegularTags = appliedTags;

  @override
  Widget build(BuildContext context) {
    final bool isCompact =
        MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;

    return Column(
      children: [
        // Rectangle bar with 7 draggable rectangles (quick-tags)
        RectangleBar(
          isCompact: isCompact,
          selectedCategory: selectedCategory, // Pass the selected category
          onRectangleSelected: (rectangle) {
            // When a rectangle is tapped, treat it as a quick-tag being added
            onTagAdded?.call(rectangle);
            debugPrint('Quick-tag selected: ${rectangle.label}');
          },
        ),

        // Note input area with callbacks passed through
        Expanded(
          child: NoteInputArea(
            headerController: headerController,
            noteController: noteController,
            headerFocusNode: headerFocusNode,
            noteFocusNode: noteFocusNode,
            appliedQuickTags: appliedQuickTags,
            appliedRegularTags: appliedRegularTags,
            onTagAdded: onTagAdded,
            onTagRemoved: onTagRemoved,
            category:
                selectedCategory, // Pass the selected category for spacing optimization
            onDelete: onDelete,
            onUndo: onUndo,
            onFormat: onFormat,
            onCamera: onCamera,
            onMic: onMic,
            onLink: onLink,
          ),
        ),

        const SizedBox(height: AppLayout.spacingS),
      ],
    );
  }
}
