// widgets/note/note_input_area.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../tag/tag_list.dart';
import '../tag/tag_chip.dart';
import 'action_button.dart';
import 'header_rectangle.dart';
import 'note_block.dart';

/// Note input area with structured note-blocks and action buttons
/// Light mode only
class NoteInputArea extends StatefulWidget {
  final TextEditingController headerController;
  final TextEditingController noteController;
  final FocusNode? headerFocusNode;
  final FocusNode? noteFocusNode;
  final List<TagData> appliedQuickTags;
  final List<TagData> appliedRegularTags;
  final Function(TagData)? onTagAdded;
  final Function(TagData)? onTagRemoved;
  final String? category;

  // Action callbacks
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;
  final VoidCallback? onFormat;
  final VoidCallback? onCamera;
  final VoidCallback? onMic;
  final VoidCallback? onLink;

  const NoteInputArea({
    super.key,
    required this.headerController,
    required this.noteController,
    this.headerFocusNode,
    this.noteFocusNode,
    this.appliedQuickTags = const [],
    this.appliedRegularTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.category,
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
    required TextEditingController controller,
    FocusNode? focusNode,
    List<TagData> appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.category,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  })  : headerController = controller,
        noteController = controller,
        headerFocusNode = focusNode,
        noteFocusNode = null,
        appliedQuickTags = const [],
        appliedRegularTags = appliedTags;

  @override
  State<NoteInputArea> createState() => _NoteInputAreaState();
}

class _NoteInputAreaState extends State<NoteInputArea> {
  // Key for drag detection bounds
  final GlobalKey _noteInputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Controllers are now passed in separately
  }

  /// Get responsive dimensions
  ({bool isCompact, double iconSize, double actionBarHeight, double padding}) _getDimensions() {
    final isCompact = MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    return (
      isCompact: isCompact,
      iconSize: AppLayout.getIconSize(context),
      actionBarHeight: isCompact ? 33.75 : 45.0,
      padding: isCompact ? 10.0 : 16.0,
    );
  }

  /// Check if dragged data should be accepted
  bool _shouldAcceptDragData(Object? data) {
    if (data is TagData) {
      final alreadyAppliedAsQuick = widget.appliedQuickTags.any((t) => t.id == data.id);
      final alreadyAppliedAsRegular = widget.appliedRegularTags.any((t) => t.id == data.id);
      return !alreadyAppliedAsQuick && !alreadyAppliedAsRegular;
    }
    return data is TagRemovalData;
  }

  /// Handle when dragged data is accepted
  void _handleDragAccept(Object data) {
    if (data is TagData && widget.onTagAdded != null) {
      widget.onTagAdded!(data);
    }
  }

  /// Handle when dragged data leaves the area
  void _handleDragLeave(Object? data) {
    if (data is TagRemovalData) {
      debugPrint('Tag dragged outside bounds: ${data.tag.label}');
      data.onRemove();
    }
  }

  /// Build the main content container with drag functionality
  Widget _buildContentContainer({
    required Widget child,
    required bool isHighlighted,
    required ThemeData theme,
  }) {
    return Container(
      key: _noteInputKey,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.shade50 : Colors.white,
        border: Border.all(
          color: isHighlighted
              ? theme.colorScheme.primary.withOpacity(0.5)
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Build the main note content area
  Widget _buildNoteContent(double actionBarHeight, double padding, bool isCompact) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Rectangle note-block
          HeaderRectangle(
            controller: widget.headerController,
            focusNode: widget.headerFocusNode,
            isCompact: isCompact,
            onChanged: (text) {
              debugPrint('Header changed: $text');
            },
          ),

          // Main Note Block
          Expanded(
            child: NoteBlock(
              controller: widget.noteController,
              focusNode: widget.noteFocusNode,
              isCompact: isCompact,
              hintText: 'Write your note here...',
              onChanged: (text) {
                debugPrint('Note content changed: ${text.length} characters');
              },
            ),
          ),

          SizedBox(height: isCompact ? 8.0 : 12.0),
        ],
      ),
    );
  }

  /// Build applied tags section
  Widget? _buildAppliedTags() {
    if (widget.appliedQuickTags.isEmpty && widget.appliedRegularTags.isEmpty) {
      return null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: TagList(
        quickTags: widget.appliedQuickTags,
        regularTags: widget.appliedRegularTags,
        onRemoveTag: widget.onTagRemoved,
        isSmall: true,
        isDraggable: true,
        category: widget.category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final theme = Theme.of(context);

    return DragTarget<Object>(
      onAccept: _handleDragAccept,
      onWillAccept: _shouldAcceptDragData,
      onLeave: _handleDragLeave,
      builder: (context, candidateItems, rejectedItems) {
        final isHighlighted = candidateItems.any((item) => item is TagData);

        return _buildContentContainer(
          isHighlighted: isHighlighted,
          theme: theme,
          child: Column(
            children: [
              // Top action bar
              TopActionBar(
                height: dimensions.actionBarHeight,
                padding: dimensions.padding,
                iconSize: dimensions.iconSize,
                onDeletePressed: widget.onDelete,
                onUndoPressed: widget.onUndo,
                onFormatPressed: widget.onFormat,
              ),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerTheme.color,
              ),

              // Main note content
              _buildNoteContent(
                dimensions.actionBarHeight,
                dimensions.padding,
                dimensions.isCompact,
              ),

              // Applied tags section
              if (_buildAppliedTags() != null) _buildAppliedTags()!,

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerTheme.color,
              ),

              // Bottom action bar
              BottomActionButtons(
                height: dimensions.actionBarHeight,
                padding: dimensions.padding,
                iconSize: dimensions.iconSize,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Spacer(flex: 1),
          ActionButton(
            icon: Icons.delete_outline,
            onPressed: onDeletePressed,
            iconSize: iconSize,
            tooltip: 'Delete note',
          ),
          const Spacer(flex: 2),
          ActionButton(
            icon: Icons.replay_outlined,
            onPressed: onUndoPressed,
            iconSize: iconSize,
            tooltip: 'Undo',
          ),
          const Spacer(flex: 2),
          ActionButton(
            icon: Icons.format_align_left,
            onPressed: onFormatPressed,
            iconSize: iconSize,
            tooltip: 'Format text',
          ),
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
          const Spacer(flex: 1),
          ActionButton(
            icon: Icons.camera_alt_outlined,
            onPressed: onCameraPressed,
            iconSize: iconSize,
            tooltip: 'Take photo',
          ),
          const Spacer(flex: 2),
          ActionButton(
            icon: Icons.mic_none_outlined,
            onPressed: onMicPressed,
            iconSize: iconSize,
            tooltip: 'Record audio',
          ),
          const Spacer(flex: 2),
          ActionButton(
            icon: Icons.link,
            onPressed: onLinkPressed,
            iconSize: iconSize,
            tooltip: 'Add link',
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}