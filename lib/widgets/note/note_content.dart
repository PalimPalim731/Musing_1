// widgets/note/note_content.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import 'note_input_area.dart';

/// Main content area with note input (size selector removed)
class NoteContent extends StatelessWidget {
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
        // Empty space where size selector was - reserved for future functionality
        SizedBox(
          height: AppLayout.selectorHeight +
              (AppLayout.spacingS * 2), // Preserves the original space
        ),

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
