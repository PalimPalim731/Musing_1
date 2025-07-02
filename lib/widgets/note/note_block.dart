// widgets/note/note_block.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Main Note Block - A larger text input area for note content
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
  ({double minHeight, double padding, double margin}) _getDimensions() {
    if (widget.isCompact) {
      return (
        minHeight: 120.0,
        padding: 12.0,
        margin: 8.0,
      );
    } else {
      return (
        minHeight: 150.0,
        padding: 16.0,
        margin: 12.0,
      );
    }
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

  /// Build hint text when input is empty and unfocused
  Widget? _buildHintText() {
    if (_isFocused || widget.controller.text.isNotEmpty) {
      return null;
    }

    final fontSize = AppLayout.getFontSize(
      context, 
      baseSize: widget.isCompact ? 14.0 : 16.0,
    );

    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(
            top: widget.isCompact ? 2.0 : 4.0,
          ),
          child: Text(
            widget.hintText ?? 'Start typing your note...',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// Build character count indicator (bottom right when focused)
  Widget? _buildCharacterCount() {
    if (!_isFocused) return null;

    final charCount = widget.controller.text.length;
    final fontSize = widget.isCompact ? 10.0 : 12.0;

    return Positioned(
      bottom: widget.isCompact ? 4.0 : 6.0,
      right: widget.isCompact ? 6.0 : 8.0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 4.0 : 6.0,
          vertical: widget.isCompact ? 2.0 : 3.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(widget.isCompact ? 8.0 : 10.0),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Text(
          '$charCount',
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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

    return Container(
      constraints: BoxConstraints(
        minHeight: dimensions.minHeight,
      ),
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
                  onChanged: (text) {
                    setState(() {}); // Trigger character count update
                    widget.onChanged?.call(text);
                  },
                ),

                // Hint text overlay
                if (_buildHintText() != null) _buildHintText()!,

                // Character count indicator
                if (_buildCharacterCount() != null) _buildCharacterCount()!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}