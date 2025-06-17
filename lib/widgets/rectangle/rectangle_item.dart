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
  final bool
      isHorizontal; // New parameter for horizontal rectangles (Public category)
  final int maxCharacters; // New parameter for character limit (3 or 10)

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
    this.isHorizontal = false, // Default to vertical/square style
    this.maxCharacters = 3, // Default to 3-character limit
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
        // Much more subtle background change - barely noticeable
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: radius,
        boxShadow: widget.isJoined
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03), // Very subtle shadow
                  blurRadius: 1,
                  offset: const Offset(0, 0.5),
                ),
              ],
        border: Border.all(
          // Much more subtle border change
          color: theme.colorScheme.primary.withOpacity(0.25),
          width: borderWidth + 0.2, // Smaller border increase
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Center(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: widget.isHorizontal
                  ? (widget.isCompact
                      ? 10.0
                      : 12.0) // Match _buildNormalText exactly
                  : (widget.isCompact ? 12.0 : 14.0),
              fontWeight: FontWeight.w600, // Match _buildNormalText exactly
              height: 1.0, // Match _buildNormalText exactly
            ),
            textAlign: TextAlign.center,
            strutStyle: StrutStyle(
              height: 1.0,
              forceStrutHeight: true, // Force consistent text baseline
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              isCollapsed: true, // Remove all internal padding
              // Show character count more subtly
              hintText:
                  '${_textController.text.length}/${widget.maxCharacters}',
              hintStyle: TextStyle(
                color: theme.colorScheme.primary.withOpacity(0.4),
                fontSize: widget.isHorizontal
                    ? (widget.isCompact ? 8.0 : 9.0)
                    : (widget.isCompact ? 10.0 : 11.0),
                height: 1.0,
              ),
            ),
            onSubmitted: (_) => _saveChanges(),
            onChanged: (text) {
              setState(() {});
            },
            maxLines: widget.isHorizontal ? 1 : null,
            maxLength: widget.maxCharacters,
            buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) =>
                null,
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
            child: _buildText(
              widget.rectangle.label,
              Colors.white,
              widget.isCompact ? 12.0 : 14.0,
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
                child: _buildText(
                  widget.rectangle.label,
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.8),
                  widget.isCompact ? 10.0 : 12.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds text based on whether it's horizontal (10 chars) or special layout (3 chars)
  Widget _buildText(String text, Color color, double baseFontSize) {
    if (widget.isHorizontal) {
      // Horizontal rectangles use normal text layout for up to 10 characters
      return _buildNormalText(text, color, baseFontSize);
    } else {
      // 3-character rectangles use special text layout
      return _buildSpecialText(text, color, baseFontSize);
    }
  }

  /// Normal text layout for horizontal rectangles (up to 10 characters)
  Widget _buildNormalText(String text, Color color, double baseFontSize) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: baseFontSize,
        fontWeight: FontWeight.w600,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  /// Special text layout for 3-character rectangles: first character twice as large,
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
