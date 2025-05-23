// widgets/note/note_input_area.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../tag/tag_list.dart';
import 'action_button.dart';

/// Note input area with text field and action buttons
class NoteInputArea extends StatelessWidget {
  final TextEditingController controller;
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

  const NoteInputArea({
    super.key,
    required this.controller,
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
    final bool isCompact = MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    final theme = Theme.of(context);
    final iconSize = AppLayout.getIconSize(context);
    final actionBarHeight = isCompact ? 45.0 : 60.0;
    final padding = isCompact ? 10.0 : 16.0;
    final contentPadding = isCompact 
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    // Create a DragTarget for tag dropping
    return DragTarget<TagData>(
      onAccept: (TagData tag) {
        if (onTagAdded != null) {
          onTagAdded!(tag);
        }
      },
      // Change visual feedback when tag is being dragged over
      onWillAccept: (TagData? tag) {
        return tag != null && !appliedTags.contains(tag);
      },
      builder: (context, candidateItems, rejectedItems) {
        // Add a subtle highlight effect when tag is hovering
        final bool isHighlighted = candidateItems.isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light 
                ? isHighlighted ? Colors.blue.shade50 : Colors.white 
                : isHighlighted ? const Color(0xFF1A2030) : const Color(0xFF1E1E1E),
            border: Border.all(
              color: isHighlighted
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.brightness == Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
            ),
            borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
            // Add subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top action bar with Format button instead of Save
              TopActionBar(
                height: actionBarHeight,
                padding: padding,
                iconSize: iconSize,
                onDeletePressed: onDelete,
                onUndoPressed: onUndo,
                onFormatPressed: onFormat,
              ),

              // Divider after top action bar
              Divider(
                height: 1, 
                thickness: 1, 
                color: theme.dividerTheme.color,
              ),

              // Text input field
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: isCompact ? 5.0 : AppLayout.spacingS),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      contentPadding: contentPadding,
                      hintText: 'Input text',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: theme.brightness == Brightness.light
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),

              // Display applied tags at the bottom left
              if (appliedTags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TagList(
                      tags: appliedTags,
                      onRemoveTag: onTagRemoved,
                      isSmall: true,
                      isScrollable: true,
                    ),
                  ),
                ),

              // Divider before bottom action bar
              Divider(
                height: 1, 
                thickness: 1, 
                color: theme.dividerTheme.color,
              ),

              // Bottom action bar
              BottomActionButtons(
                height: actionBarHeight,
                padding: padding,
                iconSize: iconSize,
                onCameraPressed: onCamera,
                onMicPressed: onMic,
                onLinkPressed: onLink,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Top action bar with note manipulation actions
class TopActionBar extends StatelessWidget {
  final double height;
  final double padding;
  final double iconSize;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onUndoPressed;
  final VoidCallback? onFormatPressed;

  const TopActionBar({
    super.key,
    required this.height,
    required this.padding,
    required this.iconSize,
    this.onDeletePressed,
    this.onUndoPressed,
    this.onFormatPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        // Evenly distribute the 3 buttons
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Spacer for better balance
          const Spacer(flex: 1),
          
          // Delete button
          ActionButton(
            icon: Icons.delete_outline,
            onPressed: onDeletePressed,
            iconSize: iconSize,
            tooltip: 'Delete note',
          ),
          
          // Center spacer
          const Spacer(flex: 2),
          
          // Undo button
          ActionButton(
            icon: Icons.replay_outlined,
            onPressed: onUndoPressed,
            iconSize: iconSize,
            tooltip: 'Undo',
          ),
          
          // Center spacer
          const Spacer(flex: 2),
          
          // Format button (changed from Save button)
          ActionButton(
            icon: Icons.format_align_left,
            onPressed: onFormatPressed,
            iconSize: iconSize,
            tooltip: 'Format text',
          ),
          
          // Spacer for better balance
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

/// Bottom action buttons for attachments
class BottomActionButtons extends StatelessWidget {
  final double height;
  final double padding;
  final double iconSize;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onMicPressed;
  final VoidCallback? onLinkPressed;

  const BottomActionButtons({
    super.key,
    required this.height,
    required this.padding,
    required this.iconSize,
    this.onCameraPressed,
    this.onMicPressed,
    this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Spacer for better balance
          const Spacer(flex: 1),
          
          // Camera button
          ActionButton(
            icon: Icons.camera_alt_outlined,
            onPressed: onCameraPressed,
            iconSize: iconSize,
            tooltip: 'Take photo',
          ),
          
          // Center spacer
          const Spacer(flex: 2),
          
          // Mic button
          ActionButton(
            icon: Icons.mic_none_outlined,
            onPressed: onMicPressed,
            iconSize: iconSize,
            tooltip: 'Record audio',
          ),
          
          // Center spacer
          const Spacer(flex: 2),
          
          // Link button
          ActionButton(
            icon: Icons.link,
            onPressed: onLinkPressed,
            iconSize: iconSize,
            tooltip: 'Add link',
          ),
          
          // Spacer for better balance
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}