// widgets/note/note_content.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import 'note_input_area.dart';
import '../rectangle/rectangle_bar.dart';

/// Main content area with note input and rectangle bar
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
    final bool isCompact =
        MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;

    return Column(
      children: [
        // Rectangle bar with 7 draggable rectangles
        RectangleBar(
          isCompact: isCompact,
          onRectangleSelected: (rectangle) {
            // When a rectangle is tapped, treat it like a tag being added
            onTagAdded?.call(rectangle);
            debugPrint('Rectangle selected: ${rectangle.label}');
          },
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
