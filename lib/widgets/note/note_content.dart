// widgets/note/note_content.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import 'size_selector.dart';
import 'note_input_area.dart';

/// Main content area with size selector and note input
class NoteContent extends StatelessWidget {
  final String selectedSize;
  final Function(String) onSizeSelected;
  final TextEditingController noteController;
  final FocusNode? focusNode;
  final List<TagData> appliedTags;
  final Function(TagData)? onTagAdded;
  final Function(TagData)? onTagRemoved;
  
  // Action callbacks
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;
  final VoidCallback? onFormat;
  final VoidCallback? onCamera;
  final VoidCallback? onMic;
  final VoidCallback? onLink;

  const NoteContent({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.noteController,
    this.focusNode,
    this.appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Size selector
        SizeSelector(
          selectedSize: selectedSize,
          onSizeSelected: onSizeSelected,
        ),

        const SizedBox(height: AppLayout.spacingS),

        // Note input area with callbacks passed through
        Expanded(
          child: NoteInputArea(
            controller: noteController,
            focusNode: focusNode,
            appliedTags: appliedTags,
            onTagAdded: onTagAdded,
            onTagRemoved: onTagRemoved,
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