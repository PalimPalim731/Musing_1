// widgets/note/note_content.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../../models/note_block_data.dart';
import '../../models/square_block_data.dart';
import 'note_input_area.dart';
import '../rectangle/rectangle_bar.dart';

/// Main content area with note input and rectangle bar
class NoteContent extends StatelessWidget {
  final TextEditingController headerController;
  final List<NoteBlockData> noteBlocks;
  final FocusNode? headerFocusNode;
  final List<TagData> appliedQuickTags;
  final List<TagData> appliedRegularTags;
  final Function(TagData)? onTagAdded;
  final Function(TagData)? onTagRemoved;
  final String selectedCategory;

  // Note block management callbacks
  final VoidCallback? onAddNoteBlock;
  final VoidCallback? onAddIndentedNoteBlock;
  final VoidCallback? onRemoveNoteBlock;
  final Function(int)? onAddSquareBlock; // NEW
  final Function(int)? onRemoveSquareBlock; // NEW

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
    required this.noteBlocks,
    this.headerFocusNode,
    this.appliedQuickTags = const [],
    this.appliedRegularTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    required this.selectedCategory,
    this.onAddNoteBlock,
    this.onAddIndentedNoteBlock,
    this.onRemoveNoteBlock,
    this.onAddSquareBlock, // NEW
    this.onRemoveSquareBlock, // NEW
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  });

  // Legacy constructor for backward compatibility
  NoteContent.legacy({
    super.key,
    required TextEditingController noteController,
    FocusNode? focusNode,
    List<TagData> appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.selectedCategory = 'Private',
    this.onAddNoteBlock,
    this.onAddIndentedNoteBlock,
    this.onRemoveNoteBlock,
    this.onAddSquareBlock,
    this.onRemoveSquareBlock,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  })  : headerController = noteController,
        noteBlocks = [
          NoteBlockData(controller: noteController, focusNode: FocusNode())
        ],
        headerFocusNode = focusNode,
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
          selectedCategory: selectedCategory,
          onRectangleSelected: (rectangle) {
            onTagAdded?.call(rectangle);
            debugPrint('Quick-tag selected: ${rectangle.label}');
          },
        ),

        // Note input area with callbacks passed through
        Expanded(
          child: NoteInputArea(
            headerController: headerController,
            noteBlocks: noteBlocks,
            headerFocusNode: headerFocusNode,
            appliedQuickTags: appliedQuickTags,
            appliedRegularTags: appliedRegularTags,
            onTagAdded: onTagAdded,
            onTagRemoved: onTagRemoved,
            category: selectedCategory,
            onAddNoteBlock: onAddNoteBlock,
            onAddIndentedNoteBlock: onAddIndentedNoteBlock,
            onRemoveNoteBlock: onRemoveNoteBlock,
            onAddSquareBlock: onAddSquareBlock, // NEW
            onRemoveSquareBlock: onRemoveSquareBlock, // NEW
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
