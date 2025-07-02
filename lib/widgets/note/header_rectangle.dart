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
  // Constants for consistent sizing
  static const int _maxCharacters = 42;
  static const int _maxLines = 2;
  static const int _charactersPerLine = 21;
  static const double _expansionMultiplierCompact = 1.0;
  static const double _expansionMultiplierNormal = 1.06;

  // State variables
  bool _isFocused = false;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _initializeFocusNode();
  }

  @override
  void dispose() {
    _disposeFocusNode();
    super.dispose();
  }

  /// Initialize focus node and listener
  void _initializeFocusNode() {
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  /// Clean up focus node and listener
  void _disposeFocusNode() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
  }

  /// Handle focus state changes
  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  /// Calculate responsive dimensions based on compact mode
  ({double baseHeight, double lineHeight, double padding, double margin}) _getDimensions() {
    if (widget.isCompact) {
      return (
        baseHeight: 30.0,
        lineHeight: 20.0,
        padding: 7.5,
        margin: 10.0,
      );
    } else {
      return (
        baseHeight: 35.0,
        lineHeight: 25.0,
        padding: 10.0,
        margin: 15.0,
      );
    }
  }

  /// Calculate dynamic height based on text content
  double _calculateDynamicHeight() {
    final dimensions = _getDimensions();
    final textLines = _calculateTextLines(widget.controller.text);
    final expansionMultiplier = widget.isCompact 
        ? _expansionMultiplierCompact 
        : _expansionMultiplierNormal;
    final reducedLineHeight = dimensions.lineHeight * expansionMultiplier;
    
    return dimensions.baseHeight + (reducedLineHeight * (textLines - 1));
  }

  /// Calculate number of lines based on character limits and word boundaries
  int _calculateTextLines(String text) {
    if (text.isEmpty) return 1;
    
    final words = text.split(' ');
    int currentLineLength = 0;
    int lineCount = 1;
    
    for (final word in words) {
      final wordLength = word.length;
      final spaceNeeded = currentLineLength > 0 ? 1 : 0; // Space before word
      
      if (currentLineLength + wordLength + spaceNeeded > _charactersPerLine) {
        if (lineCount < _maxLines) {
          lineCount++;
          currentLineLength = wordLength;
        } else {
          break; // Max lines reached
        }
      } else {
        currentLineLength += wordLength + spaceNeeded;
      }
    }
    
    return lineCount;
  }

  /// Build individual dot indicator
  Widget _buildDot() {
    final theme = Theme.of(context);
    final dotSize = widget.isCompact ? 3.0 : 4.0;
    
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isFocused
            ? theme.colorScheme.primary.withOpacity(0.6)
            : Colors.grey.shade400,
      ),
    );
  }

  /// Build the three dots indicator
  Widget _buildDotsIndicator() {
    final dotSpacing = widget.isCompact ? 3.0 : 4.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(),
        SizedBox(width: dotSpacing),
        _buildDot(),
        SizedBox(width: dotSpacing),
        _buildDot(),
      ],
    );
  }

  /// Get border and background colors based on state
  ({Color borderColor, Color backgroundColor}) _getColors() {
    final theme = Theme.of(context);
    
    if (_isFocused) {
      return (
        borderColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
      );
    } else {
      return (
        borderColor: Colors.grey.shade300,
        backgroundColor: Colors.grey.shade50,
      );
    }
  }

  /// Get responsive border width
  double _getBorderWidth() {
    final baseWidth = widget.isCompact ? 1.2 : 1.5;
    final focusedWidth = widget.isCompact ? 1.8 : 2.0;
    return _isFocused ? focusedWidth : baseWidth;
  }

  /// Get responsive shadow effects
  List<BoxShadow> _getShadows() {
    if (_isFocused) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          blurRadius: widget.isCompact ? 6.0 : 8.0,
          offset: Offset(0, widget.isCompact ? 1.5 : 2.0),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: widget.isCompact ? 1.5 : 2.0,
          offset: Offset(0, widget.isCompact ? 0.8 : 1.0),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();
    final fontSize = AppLayout.getFontSize(
      context, 
      baseSize: widget.isCompact ? 16.0 : 18.0,
    );
    final borderRadius = widget.isCompact 
        ? AppLayout.buttonRadius * 0.8 
        : AppLayout.buttonRadius;

    return Container(
      height: _calculateDynamicHeight(),
      margin: EdgeInsets.only(
        left: dimensions.margin,
        right: dimensions.margin,
        top: dimensions.margin,
        bottom: widget.isCompact ? 7.5 : 10.0, // Slightly different bottom margin
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colors.borderColor,
          width: _getBorderWidth(),
        ),
        boxShadow: _getShadows(),
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
            padding: EdgeInsets.all(dimensions.padding),
            child: Stack(
              children: [
                // Main text input field
                TextField(
                  controller: widget.controller,
                  focusNode: _internalFocusNode,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.0,
                  ),
                  strutStyle: const StrutStyle(
                    height: 1.0,
                    forceStrutHeight: true,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    isCollapsed: true,
                  ),
                  maxLines: _maxLines,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_maxCharacters),
                  ],
                  textCapitalization: TextCapitalization.words,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (text) {
                    setState(() {}); // Trigger height recalculation
                    widget.onChanged?.call(text);
                  },
                ),

                // Three dots indicator (visible when unfocused)
                if (!_isFocused)
                  Positioned(
                    bottom: widget.isCompact ? 2.0 : 3.0,
                    left: 0.0,
                    child: _buildDotsIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
