// widgets/note/note_input_area.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../tag/tag_list.dart';
import '../tag/tag_chip.dart'; // Import for TagRemovalData
import 'action_button.dart';

/// Note input area with text field and action buttons
/// Light mode only
class NoteInputArea extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<TagData> appliedQuickTags; // Rectangle-based tags (3 chars)
  final List<TagData> appliedRegularTags; // Sidebar tags (longer names)
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
    this.appliedQuickTags = const [],
    this.appliedRegularTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  });

  // Legacy constructor for backward compatibility
  const NoteInputArea.legacy({
    super.key,
    required this.controller,
    this.focusNode,
    List<TagData> appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  })  : appliedQuickTags = const [],
        appliedRegularTags = appliedTags;

  @override
  State<NoteInputArea> createState() => _NoteInputAreaState();
}

class _NoteInputAreaState extends State<NoteInputArea> {
  // Key to get the bounds of the note input area for drag detection
  final GlobalKey _noteInputKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bool isCompact =
        MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    final theme = Theme.of(context);
    final iconSize = AppLayout.getIconSize(context);
    final actionBarHeight = isCompact ? 45.0 : 60.0;
    final padding = isCompact ? 10.0 : 16.0;
    final contentPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    // Create a combined DragTarget for both tag addition and tag removal
    return DragTarget<Object>(
      onAccept: (Object data) {
        // Handle tag addition (existing functionality)
        if (data is TagData && widget.onTagAdded != null) {
          widget.onTagAdded!(data);
        }
      },
      onWillAccept: (Object? data) {
        // Accept TagData for addition
        if (data is TagData) {
          // Check if tag is already applied (existing logic)
          final alreadyAppliedAsQuick =
              widget.appliedQuickTags.any((t) => t.id == data.id);
          final alreadyAppliedAsRegular =
              widget.appliedRegularTags.any((t) => t.id == data.id);

          return !alreadyAppliedAsQuick && !alreadyAppliedAsRegular;
        }
        // Accept TagRemovalData for position tracking
        if (data is TagRemovalData) {
          return true;
        }
        return false;
      },
      onLeave: (Object? data) {
        // Handle when a tag for removal leaves the area
        if (data is TagRemovalData) {
          // Tag has been dragged outside - remove it
          debugPrint('Tag dragged outside bounds: ${data.tag.label}');
          data.onRemove();
        }
      },
      builder: (context, candidateItems, rejectedItems) {
        // Add a subtle highlight effect when tag is hovering for addition
        final bool isHighlighted =
            candidateItems.any((item) => item is TagData);

        return Container(
          key: _noteInputKey, // Key for bounds detection
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            // Light mode colors only
            color: isHighlighted ? Colors.blue.shade50 : Colors.white,
            border: Border.all(
              color: isHighlighted
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : Colors.grey.shade300,
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
                onDeletePressed: widget.onDelete,
                onUndoPressed: widget.onUndo,
                onFormatPressed: widget.onFormat,
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
                  padding: EdgeInsets.only(
                      top: isCompact ? 5.0 : AppLayout.spacingS),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    decoration: InputDecoration(
                      contentPadding: contentPadding,
                      hintText: 'Input text',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        // Light mode hint color only
                        color: Colors.grey.shade400,
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

              // Display applied tags at the bottom - separated by type
              if (widget.appliedQuickTags.isNotEmpty ||
                  widget.appliedRegularTags.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 8.0),
                  child: TagList(
                    quickTags: widget.appliedQuickTags,
                    regularTags: widget.appliedRegularTags,
                    onRemoveTag: widget.onTagRemoved,
                    isSmall: true,
                    isDraggable: true, // Enable drag-to-remove for applied tags
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
                onCameraPressed: widget.onCamera,
                onMicPressed: widget.onMic,
                onLinkPressed: widget.onLink,
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
