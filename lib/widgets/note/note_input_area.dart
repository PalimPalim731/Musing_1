// widgets/note/note_input_area.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../../models/note_block_data.dart';
import '../../utils/note_block_height_utils.dart';
import '../tag/tag_list.dart';
import '../tag/tag_chip.dart';
import 'action_button.dart';
import 'header_rectangle.dart';
import 'note_block.dart';
import 'note_block_buttons.dart';

/// Note input area with structured note-blocks and action buttons
/// Light mode only
class NoteInputArea extends StatefulWidget {
  final TextEditingController headerController;
  final List<NoteBlockData> noteBlocks; // Changed to use NoteBlockData
  final FocusNode? headerFocusNode;
  final List<TagData> appliedQuickTags;
  final List<TagData> appliedRegularTags;
  final Function(TagData)? onTagAdded;
  final Function(TagData)? onTagRemoved;
  final String? category;

  // Note block management callbacks
  final VoidCallback? onAddNoteBlock;
  final VoidCallback?
      onAddIndentedNoteBlock; // New callback for indented blocks
  final VoidCallback? onRemoveNoteBlock;

  // Action callbacks
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;
  final VoidCallback? onFormat;
  final VoidCallback? onCamera;
  final VoidCallback? onMic;
  final VoidCallback? onLink;

  // Maximum number of note blocks allowed
  static const int maxNoteBlocks = 3;

  const NoteInputArea({
    super.key,
    required this.headerController,
    required this.noteBlocks,
    this.headerFocusNode,
    this.appliedQuickTags = const [],
    this.appliedRegularTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.category,
    this.onAddNoteBlock,
    this.onAddIndentedNoteBlock,
    this.onRemoveNoteBlock,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  });

  // Legacy constructor for backward compatibility - REMOVED const
  NoteInputArea.legacy({
    super.key,
    required TextEditingController controller,
    FocusNode? focusNode,
    List<TagData> appliedTags = const [],
    this.onTagAdded,
    this.onTagRemoved,
    this.category,
    this.onAddNoteBlock,
    this.onAddIndentedNoteBlock,
    this.onRemoveNoteBlock,
    this.onDelete,
    this.onUndo,
    this.onFormat,
    this.onCamera,
    this.onMic,
    this.onLink,
  })  : headerController = controller,
        noteBlocks = [
          NoteBlockData(controller: controller, focusNode: FocusNode())
        ],
        headerFocusNode = focusNode,
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
  ({bool isCompact, double iconSize, double actionBarHeight, double padding})
      _getDimensions() {
    final isCompact =
        MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    return (
      isCompact: isCompact,
      iconSize: AppLayout.getIconSize(context),
      actionBarHeight: isCompact ? 33.75 : 45.0,
      padding: isCompact ? 10.0 : 16.0,
    );
  }

  /// Calculate the height for +/- buttons (capped at 50% of default note block height)
  double _calculateButtonHeight(bool isCompact) {
    // Get the default/base dimensions for note blocks
    final dimensions = NoteBlockHeightUtils.getDimensions(context, isCompact: isCompact);
    
    // Return 50% of the base height as the maximum button height
    return dimensions.baseHeight * 0.5;
  }

  /// Calculate the indentation for +/- buttons to match the latest note block
  double _calculateButtonIndentation(bool isCompact) {
    if (widget.noteBlocks.isEmpty) {
      return 0.0; // No indentation if no blocks
    }

    final lastBlock = widget.noteBlocks.last;
    final dimensions = NoteBlockHeightUtils.getDimensions(
      context, 
      isCompact: isCompact, 
      indentLevel: lastBlock.indentLevel
    );
    
    // Return the same indentation offset as the last note block
    return dimensions.indentOffset;
  }

  /// Check if dragged data should be accepted
  bool _shouldAcceptDragData(Object? data) {
    if (data is TagData) {
      final alreadyAppliedAsQuick =
          widget.appliedQuickTags.any((t) => t.id == data.id);
      final alreadyAppliedAsRegular =
          widget.appliedRegularTags.any((t) => t.id == data.id);
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
  Widget _buildNoteContent(
      double actionBarHeight, double padding, bool isCompact) {
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

          // Multiple Note Blocks with Plus/Minus buttons positioned after the last block
          Expanded(
            child: ListView.builder(
              itemCount: widget.noteBlocks.length + 1, // +1 for the buttons
              itemBuilder: (context, index) {
                // Show note blocks first
                if (index < widget.noteBlocks.length) {
                  final noteBlock = widget.noteBlocks[index];
                  return NoteBlock(
                    controller: noteBlock.controller,
                    focusNode: noteBlock.focusNode,
                    indentLevel:
                        noteBlock.indentLevel, // Pass indentation level
                    isCompact: isCompact,
                    hintText: index == 0
                        ? 'Write your note here...'
                        : noteBlock.isIndented
                            ? 'Add sub-point...'
                            : 'Continue your note...',
                    onChanged: (text) {
                      debugPrint(
                          'Note block ${index + 1} changed: ${text.length} characters (indent: ${noteBlock.indentLevel})');
                      // Note: Button indentation updates when blocks are added/removed, not on text change
                    },
                  );
                } else {
                  // Show Plus/Minus buttons after the last note block
                  // Height is capped at 50% of the default note block size
                  // Width adapts to match indentation of the latest note block
                  final buttonHeight = _calculateButtonHeight(isCompact);
                  final buttonIndentation = _calculateButtonIndentation(isCompact);
                  
                  return NoteBlockButtons(
                    onAddBlock: widget.onAddNoteBlock,
                    onAddIndentedBlock: widget.onAddIndentedNoteBlock,
                    onRemoveBlock: widget.onRemoveNoteBlock,
                    canRemoveBlock: widget.noteBlocks.length >
                        1, // Can't remove if only one block
                    canAddBlock: widget.noteBlocks.length <
                        NoteInputArea
                            .maxNoteBlocks, // Can't add if at max blocks
                    isCompact: isCompact,
                    adaptiveHeight: buttonHeight, // Fixed height (50% of default note block)
                    indentationOffset: buttonIndentation, // Match indentation of latest note block
                  );
                }
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