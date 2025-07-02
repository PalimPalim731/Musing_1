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

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
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

  /// Calculate how many lines the text should occupy based on 21-character limit per line
  int _calculateTextLines(String text) {
    if (text.isEmpty) return 1;

    const int maxCharactersPerLine = 21;
    final words = text.split(' ');
    int currentLineLength = 0;
    int lineCount = 1;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final wordLength = word.length;

      // Check if adding this word would exceed the line limit
      if (currentLineLength + wordLength + (currentLineLength > 0 ? 1 : 0) >
          maxCharactersPerLine) {
        // Move to next line if we haven't reached the max line limit
        if (lineCount < 2) {
          lineCount++;
          currentLineLength = wordLength;
        } else {
          // We've reached max lines, stop calculating
          break;
        }
      } else {
        // Add word to current line
        currentLineLength +=
            wordLength + (currentLineLength > 0 ? 1 : 0); // +1 for space
      }
    }

    return lineCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate responsive dimensions - Increased by 25% across the board
    final double baseHeight =
        widget.isCompact ? 30.0 : 35.0; // Was 24/28, now +25%
    final double lineHeight =
        widget.isCompact ? 20.0 : 25.0; // Was 16/20, now +25%

    // Calculate dynamic height based on text content (max 2 lines)
    final textLines = _calculateTextLines(widget.controller.text);
    // Responsive expansion multiplier - increased proportionally with 25% larger base
    final double expansionMultiplier =
        widget.isCompact ? 1.0 : 1.06; // Slightly increased from 0.8/0.85
    final double reducedLineHeight = lineHeight * expansionMultiplier;
    final double dynamicHeight =
        baseHeight + (reducedLineHeight * (textLines - 1));

    final double borderRadius = widget.isCompact
        ? AppLayout.buttonRadius * 0.8
        : AppLayout.buttonRadius;
    final double fontSize = AppLayout.getFontSize(context,
        baseSize: widget.isCompact ? 16.0 : 18.0);
    final EdgeInsets padding = widget.isCompact
        ? const EdgeInsets.all(7.5) // Was 6.0, now +25% = 7.5
        : const EdgeInsets.all(10.0); // Was 8.0, now +25% = 10.0

    // Define colors based on state
    Color borderColor;
    Color backgroundColor;

    if (_isFocused) {
      borderColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primary.withOpacity(0.05);
    } else {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.grey.shade50;
    }

    return Container(
      height: dynamicHeight,
      margin: EdgeInsets.only(
        left: widget.isCompact ? 10.0 : 15.0, // Was 8/12, now +25% = 10/15
        right: widget.isCompact ? 10.0 : 15.0, // Was 8/12, now +25% = 10/15
        top: widget.isCompact ? 10.0 : 15.0, // Was 8/12, now +25% = 10/15
        bottom: widget.isCompact ? 7.5 : 10.0, // Was 6/8, now +25% = 7.5/10
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: _isFocused
              ? (widget.isCompact ? 1.8 : 2.0) // Responsive focused border
              : (widget.isCompact ? 1.2 : 1.5), // Responsive unfocused border
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: widget.isCompact ? 6.0 : 8.0, // Responsive blur
                  offset: Offset(
                      0, widget.isCompact ? 1.5 : 2.0), // Responsive offset
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: widget.isCompact ? 1.5 : 2.0, // Responsive blur
                  offset: Offset(
                      0, widget.isCompact ? 0.8 : 1.0), // Responsive offset
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
                    height: widget.isCompact
                        ? 1.0
                        : 1.0, // Responsive line height (same for now, but consistent pattern)
                  ),
                  strutStyle: StrutStyle(
                    height:
                        widget.isCompact ? 1.0 : 1.0, // Responsive strut height
                    forceStrutHeight: true, // Force consistent text baseline
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: null,
                    contentPadding: EdgeInsets.all(
                      widget.isCompact
                          ? 0.0
                          : 0.0, // Equal minimal padding on ALL sides
                    ),
                    isDense: true,
                    isCollapsed: true, // Remove all internal padding
                  ),
                  maxLines: 2, // Allow up to 2 lines for display
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        42), // Hard limit: 42 characters total
                  ],
                  textCapitalization: TextCapitalization.words,
                  onChanged: (text) {
                    setState(() {}); // Trigger height recalculation
                    widget.onChanged?.call(text);
                  },
                  textAlignVertical: TextAlignVertical
                      .center, // Center text vertically for equal spacing
                ),

                // Three discrete dots positioned at bottom left corner (disappear when focused)
                if (!_isFocused)
                  Positioned(
                    bottom: widget.isCompact
                        ? 2.0
                        : 3.0, // Adjusted for new container size
                    left: widget.isCompact
                        ? 0.0
                        : 0.0, // Match exactly where text starts
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
