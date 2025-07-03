// widgets/note/note_content.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import 'note_input_area.dart';
import '../rectangle/rectangle_bar.dart';

/// Main content area with note input and rectangle bar
class NoteContent extends StatelessWidget {
  final TextEditingController headerController;
  final List<TextEditingController>
      noteControllers; // Changed to support multiple blocks
  final FocusNode? headerFocusNode;
  final List<FocusNode?> noteFocusNodes; // Changed to support multiple blocks
  final List<TagData> appliedQuickTags; // Rectangle-based tags (3 chars)
  final List<TagData> appliedRegularTags; // Sidebar tags (longer names)
  final Function(TagData)? onTagAdded;
  final Function(TagData)? onTagRemoved;
  final String selectedCategory; // Add category parameter

  // Note block management callbacks
  final VoidCallback? onAddNoteBlock;
  final VoidCallback? onRemoveNoteBlock;

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
    required this.noteControllers,
    this.headerFocusNode,
    required this.noteFocusNodes,
    this.appliedQuickTags = const [],
    this.appliedRegularTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    required this.selectedCategory, // Add required category parameter
    this.onAddNoteBlock,
    this.onRemoveNoteBlock,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  });

  // Legacy constructor for backward compatibility - REMOVED const
  NoteContent.legacy({
    super.key,
    required TextEditingController noteController,
    FocusNode? focusNode,
    List<TagData> appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.selectedCategory = 'Private', // Default category for legacy
    this.onAddNoteBlock,
    this.onRemoveNoteBlock,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  })  : headerController = noteController,
        noteControllers = [noteController],
        headerFocusNode = focusNode,
        noteFocusNodes = [null],
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
            noteControllers: noteControllers,
            headerFocusNode: headerFocusNode,
            noteFocusNodes: noteFocusNodes,
            appliedQuickTags: appliedQuickTags,
            appliedRegularTags: appliedRegularTags,
            onTagAdded: onTagAdded,
            onTagRemoved: onTagRemoved,
            category:
                selectedCategory, // Pass the selected category for spacing optimization
            onAddNoteBlock: onAddNoteBlock,
            onRemoveNoteBlock: onRemoveNoteBlock,
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
