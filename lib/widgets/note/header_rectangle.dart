// widgets/note/header_rectangle.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/constants/layout.dart';

/// Header Rectangle - A predefined rectangular input area for note headers/titles
/// Positioned at the top of the note input area
class HeaderRectangle extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isCompact;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  const HeaderRectangle({
    super.key,
    required this.controller,
    this.focusNode,
    this.isCompact = false,
    this.onChanged,
    this.onTap,
  });

  @override
  State<HeaderRectangle> createState() => _HeaderRectangleState();
}

class _HeaderRectangleState extends State<HeaderRectangle> {
  bool _isFocused = false;
  late FocusNode _internalFocusNode;
  String _lastValidText = '';
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
    _lastValidText = widget.controller.text;

    // Listen to controller changes to enforce 2-line limit
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    // Check if current text exceeds 2 lines
    if (_textExceedsTwoLines(widget.controller.text)) {
      // Revert to last valid text
      widget.controller.text = _lastValidText;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _lastValidText.length),
      );
    } else {
      // Update last valid text
      _lastValidText = widget.controller.text;
      setState(() {}); // Trigger rebuild for height adjustment
    }
  }

  bool _textExceedsTwoLines(String text) {
    if (text.isEmpty) return false;

    // Get the render box to measure actual width
    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      // Fallback: estimate width if render box not available
      return _estimateIfTextExceedsTwoLines(text);
    }

    final double availableWidth = renderBox.size.width;
    final double fontSize = AppLayout.getFontSize(context,
        baseSize: widget.isCompact ? 16.0 : 18.0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: availableWidth);
    final lineCount = textPainter.computeLineMetrics().length;
    textPainter.dispose();

    return lineCount > 2;
  }

  bool _estimateIfTextExceedsTwoLines(String text) {
    // Rough estimation when render box is not available
    // This will be refined once the widget is built
    return text.length > 60; // Conservative estimate
  }

  Widget _buildDot(ThemeData theme) {
    return Container(
      width: widget.isCompact ? 3.0 : 4.0,
      height: widget.isCompact ? 3.0 : 4.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isFocused
            ? theme.colorScheme.primary.withOpacity(0.6)
            : Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasContent = widget.controller.text.isNotEmpty;

    // Calculate responsive dimensions
    final double baseHeight = widget.isCompact ? 48.0 : 56.0;
    final double lineHeight = widget.isCompact ? 20.0 : 24.0;

    // Simple height calculation: expand when text is getting long
    final bool isLongText = widget.controller.text.length > 25;
    final double dynamicHeight =
        isLongText ? baseHeight + lineHeight : baseHeight;

    final double borderRadius = widget.isCompact
        ? AppLayout.buttonRadius * 0.8
        : AppLayout.buttonRadius;
    final double fontSize = AppLayout.getFontSize(context,
        baseSize: widget.isCompact ? 16.0 : 18.0);
    final EdgeInsets padding = widget.isCompact
        ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    // Define colors based on state
    Color borderColor;
    Color backgroundColor;

    if (_isFocused) {
      borderColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primary.withOpacity(0.05);
    } else if (hasContent) {
      borderColor = theme.colorScheme.primary.withOpacity(0.6);
      backgroundColor = theme.colorScheme.primary.withOpacity(0.03);
    } else {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.grey.shade50;
    }

    return Container(
      height: dynamicHeight,
      margin: EdgeInsets.only(
        left: widget.isCompact ? 8.0 : 12.0,
        right: widget.isCompact ? 8.0 : 12.0,
        top: widget.isCompact ? 8.0 : 12.0,
        bottom: widget.isCompact ? 6.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            _internalFocusNode.requestFocus();
            widget.onTap?.call();
          },
          child: Padding(
            padding: padding,
            child: Stack(
              children: [
                // Text input taking full space
                TextField(
                  controller: widget.controller,
                  focusNode: _internalFocusNode,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: null,
                    contentPadding: EdgeInsets.only(
                      top: widget.isCompact ? 8.0 : 12.0,
                      bottom: widget.isCompact ? 16.0 : 20.0,
                      left: 0,
                      right: 0,
                    ),
                    isDense: true,
                  ),
                  maxLines: 2, // Allow up to 2 lines for display
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        52), // BRUTE FORCE: Block 53rd character
                  ],
                  textCapitalization: TextCapitalization.words,
                  onChanged: (text) {
                    setState(() {}); // Trigger height recalculation
                    widget.onChanged?.call(text);
                  },
                  textAlignVertical: TextAlignVertical.top,
                ),

                // Three discrete dots positioned at bottom left corner (only when empty)
                if (!hasContent)
                  Positioned(
                    bottom: widget.isCompact ? 4.0 : 6.0,
                    left: 0.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(theme),
                        SizedBox(width: widget.isCompact ? 3.0 : 4.0),
                        _buildDot(theme),
                        SizedBox(width: widget.isCompact ? 3.0 : 4.0),
                        _buildDot(theme),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
