// widgets/note/note_block.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/constants/layout.dart';

/// Main Note Block - A dynamically expanding text input area for note content
/// Positioned below the header rectangle
class NoteBlock extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isCompact;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final String? hintText;

  const NoteBlock({
    super.key,
    required this.controller,
    this.focusNode,
    this.isCompact = false,
    this.onChanged,
    this.onTap,
    this.hintText,
  });

  @override
  State<NoteBlock> createState() => _NoteBlockState();
}

class _NoteBlockState extends State<NoteBlock> {
  // Constants for the note block
  static const int _maxCharacters = 100;
  static const int _averageCharsPerLine = 45; // Estimated characters per line

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
        baseHeight: 60.0, // Reduced from 120.0 to double the header size
        lineHeight: 18.0,
        padding: 12.0,
        margin: 8.0,
      );
    } else {
      return (
        baseHeight: 70.0, // Reduced from 150.0 to double the header size
        lineHeight: 22.0,
        padding: 16.0,
        margin: 12.0,
      );
    }
  }

  /// Calculate dynamic height based on text content
  double _calculateDynamicHeight() {
    final dimensions = _getDimensions();
    final text = widget.controller.text;
    
    if (text.isEmpty) {
      return dimensions.baseHeight;
    }

    // Calculate approximate number of lines based on character count and actual line breaks
    final manualLineBreaks = '\n'.allMatches(text).length;
    final estimatedWrappedLines = (text.length / _averageCharsPerLine).ceil();
    final totalLines = manualLineBreaks + estimatedWrappedLines;
    
    // Ensure at least 1 line
    final lines = totalLines < 1 ? 1 : totalLines;
    
    // Calculate height: base height + additional lines
    final additionalHeight = (lines - 1) * dimensions.lineHeight;
    return dimensions.baseHeight + additionalHeight;
  }

  /// Get border and background colors based on state
  ({Color borderColor, Color backgroundColor}) _getColors() {
    final theme = Theme.of(context);
    
    if (_isFocused) {
      return (
        borderColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.03),
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
    final baseWidth = widget.isCompact ? 1.0 : 1.2;
    final focusedWidth = widget.isCompact ? 1.5 : 1.8;
    return _isFocused ? focusedWidth : baseWidth;
  }

  /// Get responsive shadow effects
  List<BoxShadow> _getShadows() {
    if (_isFocused) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          blurRadius: widget.isCompact ? 4.0 : 6.0,
          offset: Offset(0, widget.isCompact ? 1.0 : 1.5),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: widget.isCompact ? 1.0 : 1.5,
          offset: Offset(0, widget.isCompact ? 0.5 : 0.8),
        ),
      ];
    }
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

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();
    final fontSize = AppLayout.getFontSize(
      context, 
      baseSize: widget.isCompact ? 14.0 : 16.0,
    );
    final borderRadius = widget.isCompact 
        ? AppLayout.buttonRadius * 0.8 
        : AppLayout.buttonRadius;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Smooth expansion animation
      curve: Curves.easeOutCubic,
      height: _calculateDynamicHeight(),
      margin: EdgeInsets.symmetric(
        horizontal: dimensions.margin,
        vertical: widget.isCompact ? 6.0 : 8.0,
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
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4, // Better line spacing for longer text
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    isCollapsed: true,
                  ),
                  maxLines: null, // Allow unlimited lines
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  // Add character limit
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_maxCharacters),
                  ],
                  onChanged: (text) {
                    setState(() {}); // Trigger height recalculation
                    widget.onChanged?.call(text);
                  },
                ),

                // Three dots indicator (visible when unfocused and empty)
                if (!_isFocused && widget.controller.text.isEmpty)
                  Positioned(
                    bottom: widget.isCompact ? 4.0 : 6.0,
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