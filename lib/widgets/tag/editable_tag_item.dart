// widgets/tag/editable_tag_item.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../../utils/text_utils.dart';

/// A version of TagItem that can be edited via long press
class EditableTagItem extends StatefulWidget {
  final double height;
  final VoidCallback? onTap;
  final Function(String) onRename;
  final TagData tag;
  final bool isCompact;

  const EditableTagItem({
    super.key,
    required this.height,
    this.onTap,
    required this.onRename,
    required this.tag,
    this.isCompact = false,
  });

  @override
  State<EditableTagItem> createState() => _EditableTagItemState();
}

class _EditableTagItemState extends State<EditableTagItem> {
  bool _isEditing = false;
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.tag.label);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // When focus is lost, exit editing mode and save changes
    if (!_focusNode.hasFocus && _isEditing) {
      _saveChanges();
    }
  }

  void _saveChanges() {
    final newLabel = _textController.text.trim();
    if (newLabel.isNotEmpty && newLabel != widget.tag.label) {
      widget.onRename(newLabel);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      // Ensure text controller has the current tag label
      _textController.text = widget.tag.label;
    });
    // Schedule focus for after the build phase
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.tag.isSelected;
    final radius = widget.isCompact ? AppLayout.tagRadius * 0.8 : AppLayout.tagRadius;
    final fontSize = AppLayout.getFontSize(context, 
        baseSize: widget.isCompact ? 12.0 : 14.0);
    final borderWidth = isSelected 
        ? (widget.isCompact ? 1.2 : 1.5)
        : (widget.isCompact ? 0.8 : 1.0);

    if (_isEditing) {
      return _buildEditingMode(theme, radius, fontSize, borderWidth);
    } else {
      return _buildNormalMode(theme, isSelected, radius, fontSize, borderWidth);
    }
  }

  Widget _buildEditingMode(ThemeData theme, double radius, double fontSize, double borderWidth) {
    // This is a non-draggable mode just for editing
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.6),
          width: borderWidth + 0.5, // Make border slightly thicker in edit mode
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: RotatedBox(
            quarterTurns: 3, // Keep the rotation consistent with normal mode
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show the current full tag name above the text field
                if (widget.tag.label.length > 7)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      widget.tag.label,
                      style: TextStyle(
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        fontSize: fontSize * 0.8,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Text field for editing
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    // Add a suffix that shows how many characters are used
                    suffix: _textController.text.length > 7 
                        ? Text(
                            "(${_textController.text.length})",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: fontSize * 0.8,
                            ),
                          ) 
                        : null,
                  ),
                  // Handle keyboard submission
                  onSubmitted: (_) => _saveChanges(),
                  // Update the UI as the user types
                  onChanged: (text) {
                    setState(() {
                      // Just trigger a rebuild
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalMode(ThemeData theme, bool isSelected, double radius, double fontSize, double borderWidth) {
    // Wrap with Draggable widget
    return Draggable<TagData>(
      // The data that will be passed to the DragTarget
      data: widget.tag,
      // What is displayed as the dragged item during drag
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            TextUtils.truncateWithEllipsis(widget.tag.label, 7),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Reduce the opacity of the original widget during drag
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTagItem(theme, isSelected, radius, fontSize, borderWidth),
      ),
      // The actual widget displayed when not dragging
      child: GestureDetector(
        // Use onDoubleTap to enter edit mode
        onDoubleTap: _startEditing,
        child: _buildTagItem(theme, isSelected, radius, fontSize, borderWidth),
      ),
    );
  }

  // Extracted the original tag item widget to reduce code duplication
  Widget _buildTagItem(ThemeData theme, bool isSelected, double radius, double fontSize, double borderWidth) {
    return Semantics(
      label: widget.tag.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.colorScheme.primary.withOpacity(0.15),
              width: borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: widget.onTap,
              splashColor: theme.colorScheme.primary.withOpacity(0.15),
              highlightColor: theme.colorScheme.primary.withOpacity(0.1),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    TextUtils.truncateWithEllipsis(widget.tag.label, 7),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.8),
                      fontSize: fontSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}