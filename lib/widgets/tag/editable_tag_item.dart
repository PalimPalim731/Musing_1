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
    final radius =
        widget.isCompact ? AppLayout.tagRadius * 0.8 : AppLayout.tagRadius;
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

  Widget _buildEditingMode(
      ThemeData theme, double radius, double fontSize, double borderWidth) {
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.height - 8.0, // Account for padding
                  maxWidth: double.infinity,
                ),
                child: TextField(
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
                    // Simplified hint text instead of complex suffix
                    hintText:
                        _textController.text.length > 7 ? 'Too long!' : null,
                    hintStyle: TextStyle(
                      color: Colors.red.withOpacity(0.7),
                      fontSize: fontSize * 0.8,
                    ),
                  ),
                  // Handle keyboard submission
                  onSubmitted: (_) => _saveChanges(),
                  // Update the UI as the user types
                  onChanged: (text) {
                    setState(() {
                      // Just trigger a rebuild for hint text update
                    });
                  },
                  // Prevent line breaks
                  maxLines: 1,
                  // Set a reasonable max length
                  maxLength: 15,
                  // Hide the counter
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalMode(ThemeData theme, bool isSelected, double radius,
      double fontSize, double borderWidth) {
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
      child: _buildTagItem(theme, isSelected, radius, fontSize, borderWidth),
    );
  }

  // Extracted the original tag item widget to reduce code duplication
  Widget _buildTagItem(ThemeData theme, bool isSelected, double radius,
      double fontSize, double borderWidth) {
    return Semantics(
      label: widget.tag.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _startEditing, // Add double-tap to enter edit mode
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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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
