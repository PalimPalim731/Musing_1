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
    final bool hasContent = widget.controller.text.isNotEmpty;

    // Calculate responsive dimensions
    final double baseHeight = widget.isCompact ? 48.0 : 56.0;
    final double lineHeight = widget.isCompact ? 20.0 : 24.0;

    // Calculate dynamic height based on text content (max 2 lines)
    final textLines = _calculateTextLines(widget.controller.text);
    final double dynamicHeight = baseHeight + (lineHeight * (textLines - 1));

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
                    hintText: null, // No placeholder text
                    contentPadding: EdgeInsets.only(
                      top: widget.isCompact ? 8.0 : 12.0,
                      bottom: widget.isCompact
                          ? 16.0
                          : 20.0, // Extra bottom padding for dots
                      left: widget.isCompact
                          ? 0
                          : 0, // Your change - text at very edge
                      right: widget.isCompact
                          ? 0
                          : 0, // Your change - text at very edge
                    ),
                    isDense: true,
                  ),
                  maxLines: 2, // Allow up to 2 lines
                  inputFormatters: [
                    _TwoLineTextFormatter(), // Custom formatter to enforce 2-line limit
                  ],
                  textCapitalization: TextCapitalization.words,
                  onChanged: (text) {
                    // Trigger rebuild to adjust height dynamically
                    setState(() {});
                    widget.onChanged?.call(text);
                  },
                  textAlignVertical: TextAlignVertical.top,
                ),

                // Three discrete dots positioned at bottom left corner (only when empty)
                if (!hasContent)
                  Positioned(
                    bottom: widget.isCompact ? 4.0 : 6.0,
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

/// Custom TextInputFormatter to enforce 2-line limit with 21 characters per line
/// and word-boundary respect
class _TwoLineTextFormatter extends TextInputFormatter {
  static const int maxCharactersPerLine = 21;
  static const int maxLines = 2;
  static const int maxTotalCharacters =
      maxCharactersPerLine * maxLines; // 42 total

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If text is being deleted, always allow it
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Hard limit: Never allow more than 42 characters total (21 chars × 2 lines)
    if (newValue.text.length > maxTotalCharacters) {
      return oldValue;
    }

    // Check if the new text would fit within our constraints
    if (_wouldTextFitInLines(newValue.text)) {
      return newValue;
    } else {
      // Reject the new input and keep the old value
      return oldValue;
    }
  }

  /// Check if the given text would fit within 2 lines of 21 characters each
  /// respecting word boundaries when possible
  bool _wouldTextFitInLines(String text) {
    if (text.isEmpty) return true;

    // Hard character limit check first
    if (text.length > maxTotalCharacters) return false;

    // If text has no spaces, check if it fits in character limits
    if (!text.contains(' ')) {
      return text.length <= maxTotalCharacters;
    }

    // For text with spaces, use word boundary logic
    final words = text.split(' ');
    int currentLineLength = 0;
    int lineCount = 1;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final wordLength = word.length;

      // If a single word is longer than one line, reject it
      if (wordLength > maxCharactersPerLine) {
        return false;
      }

      // Check if adding this word would exceed the line limit
      if (currentLineLength + wordLength + (currentLineLength > 0 ? 1 : 0) >
          maxCharactersPerLine) {
        // Would need to move to next line
        if (lineCount < maxLines) {
          lineCount++;
          currentLineLength = wordLength;
        } else {
          // Would exceed max lines - reject
          return false;
        }
      } else {
        // Add word to current line
        currentLineLength +=
            wordLength + (currentLineLength > 0 ? 1 : 0); // +1 for space
      }
    }

    return true;
  }
}
