// widgets/rectangle/rectangle_item.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';

/// A rectangle item that can be edited and dragged, with special text layout
class RectangleItem extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;
  final Function(String) onRename;
  final TagData rectangle;
  final bool isCompact;
  final bool isJoined; // New parameter for joined style (Circle category)
  final bool isFirst; // New parameter to indicate first item in joined layout
  final bool isLast; // New parameter to indicate last item in joined layout
  final bool isCircular; // New parameter for circular style (Public category)

  const RectangleItem({
    super.key,
    required this.width,
    required this.height,
    this.onTap,
    required this.onRename,
    required this.rectangle,
    this.isCompact = false,
    this.isJoined = false, // Default to separated style
    this.isFirst = false,
    this.isLast = false,
    this.isCircular = false, // Default to rectangular style
  });

  @override
  State<RectangleItem> createState() => _RectangleItemState();
}

class _RectangleItemState extends State<RectangleItem> {
  bool _isEditing = false;
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.rectangle.label);
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
    if (newLabel.isNotEmpty && newLabel != widget.rectangle.label) {
      widget.onRename(newLabel);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      // Ensure text controller has the current rectangle label
      _textController.text = widget.rectangle.label;
    });
    // Schedule focus for after the build phase
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.rectangle.isSelected;

    // For joined style, only first and last items have rounded corners
    // For circular style, always use circular radius
    BorderRadius getRadius() {
      if (widget.isCircular) {
        // Circular style - make it a perfect circle
        final radius =
            widget.width / 2; // Use half the width for perfect circle
        return BorderRadius.circular(radius);
      } else if (!widget.isJoined) {
        // Normal separated style - all corners rounded
        return BorderRadius.circular(widget.isCompact
            ? AppLayout.buttonRadius * 0.8
            : AppLayout.buttonRadius);
      } else {
        // Joined style - selective corner rounding
        final radius = widget.isCompact
            ? AppLayout.buttonRadius * 0.8
            : AppLayout.buttonRadius;

        if (widget.isFirst && widget.isLast) {
          // Single item (shouldn't happen with 7 items, but for safety)
          return BorderRadius.circular(radius);
        } else if (widget.isFirst) {
          // First item - left corners rounded
          return BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
        } else if (widget.isLast) {
          // Last item - right corners rounded
          return BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
        } else {
          // Middle items - no rounded corners
          return BorderRadius.zero;
        }
      }
    }

    final radius = getRadius();
    final borderWidth = isSelected
        ? (widget.isCompact ? 1.5 : 2.0)
        : (widget.isCompact ? 1.0 : 1.2);

    if (_isEditing) {
      return _buildEditingMode(theme, radius, borderWidth);
    } else {
      return _buildNormalMode(theme, isSelected, radius, borderWidth);
    }
  }

  Widget _buildEditingMode(
      ThemeData theme, BorderRadius radius, double borderWidth) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.6),
          width: borderWidth + 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: widget.isCompact ? 14.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: '${_textController.text.length}/3',
                hintStyle: TextStyle(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  fontSize: (widget.isCompact ? 14.0 : 16.0) * 0.8,
                ),
              ),
              onSubmitted: (_) => _saveChanges(),
              onChanged: (text) {
                setState(() {});
              },
              maxLines: 1,
              maxLength: 3,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalMode(ThemeData theme, bool isSelected, BorderRadius radius,
      double borderWidth) {
    return Draggable<TagData>(
      data: widget.rectangle,
      feedback: Material(
        elevation: 4.0,
        borderRadius: radius,
        child: Container(
          width: widget.width * 1.1,
          height: widget.height * 1.1,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.9),
            borderRadius: radius,
          ),
          child: Center(
            child: _buildSpecialText(
              widget.rectangle.label,
              Colors.white,
              widget.isCompact ? 14.0 : 16.0,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildRectangleItem(theme, isSelected, radius, borderWidth),
      ),
      child: _buildRectangleItem(theme, isSelected, radius, borderWidth),
    );
  }

  Widget _buildRectangleItem(ThemeData theme, bool isSelected,
      BorderRadius radius, double borderWidth) {
    return Semantics(
      label: widget.rectangle.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _startEditing,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: radius,
            boxShadow: widget.isJoined
                ? null
                : [
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
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: widget.onTap,
              splashColor: theme.colorScheme.primary.withOpacity(0.15),
              highlightColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Center(
                child: _buildSpecialText(
                  widget.rectangle.label,
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.8),
                  widget.isCompact ? 12.0 : 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the special text layout: first character twice as large,
  /// other two characters half size and stacked vertically to the right
  Widget _buildSpecialText(String text, Color color, double baseFontSize) {
    // Ensure we have at least 1 character, pad with spaces if needed
    final paddedText = text.padRight(3, ' ');
    final firstChar = paddedText[0];
    final secondChar = paddedText.length > 1 ? paddedText[1] : ' ';
    final thirdChar = paddedText.length > 2 ? paddedText[2] : ' ';

    // Adjust font sizes for circular containers
    final largeFontSize = widget.isCircular
        ? baseFontSize * 1.3 // Slightly smaller for circular containers
        : baseFontSize * 1.5; // Original size for rectangular
    final smallFontSize = widget.isCircular
        ? baseFontSize * 0.65 // Slightly smaller for circular containers
        : baseFontSize * 0.75; // Original size for rectangular

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // First character (large)
        Text(
          firstChar,
          style: TextStyle(
            color: color,
            fontSize: largeFontSize,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),

        // Small spacing between first and other characters
        SizedBox(
            width: widget.isCircular ? 1.5 : 2), // Tighter spacing for circles

        // Second and third characters (small, stacked vertically)
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              secondChar,
              style: TextStyle(
                color: color,
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            Text(
              thirdChar,
              style: TextStyle(
                color: color,
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
