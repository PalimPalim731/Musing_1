// lib/widgets/note/note_block_buttons.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import 'dart:async';

/// Plus and minus buttons for adding/removing note blocks
/// Height is fixed at 50% of the default note block size
/// Width adapts to match indentation of the latest note block
class NoteBlockButtons extends StatefulWidget {
  final VoidCallback? onAddBlock;
  final VoidCallback? onAddIndentedBlock; // Long press handler
  final VoidCallback? onRemoveBlock;
  final VoidCallback? onDoublePress; // NEW: Double press handler
  final bool canRemoveBlock; // Whether removal is allowed
  final bool canAddBlock; // Whether adding more blocks is allowed
  final bool isCompact;
  final double? adaptiveHeight; // Fixed height (50% of default note block size)
  final double indentationOffset; // Indentation to match latest note block
  final bool isInline; // NEW: Whether buttons are inline with square blocks

  const NoteBlockButtons({
    super.key,
    this.onAddBlock,
    this.onAddIndentedBlock,
    this.onRemoveBlock,
    this.onDoublePress, // NEW
    this.canRemoveBlock = true,
    this.canAddBlock = true,
    this.isCompact = false,
    this.adaptiveHeight,
    this.indentationOffset = 0.0,
    this.isInline = false, // NEW
  });

  @override
  State<NoteBlockButtons> createState() => _NoteBlockButtonsState();
}

class _NoteBlockButtonsState extends State<NoteBlockButtons> {
  DateTime? _lastTap;
  Timer? _singleTapTimer;
  static const int _doubleTapDelay = 500; // milliseconds

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    super.dispose();
  }

  void _handlePlusTap() {
    final now = DateTime.now();

    if (_lastTap != null &&
        now.difference(_lastTap!).inMilliseconds < _doubleTapDelay) {
      // Double tap detected
      _singleTapTimer?.cancel(); // Cancel any pending single tap
      _lastTap = null; // Reset

      if (widget.onDoublePress != null) {
        debugPrint('Double-tap detected!');
        widget.onDoublePress!();
      }
    } else {
      // Potential single tap - wait to see if it becomes a double tap
      _lastTap = now;
      _singleTapTimer?.cancel();

      _singleTapTimer = Timer(Duration(milliseconds: _doubleTapDelay), () {
        // If we get here, it was a single tap
        if (widget.canAddBlock && widget.onAddBlock != null) {
          debugPrint('Single-tap executed');
          widget.onAddBlock!();
        }
        _lastTap = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use fixed height if provided, otherwise fall back to default sizing
    final buttonHeight =
        widget.adaptiveHeight ?? (widget.isCompact ? 35.0 : 40.0);

    final fontSize = AppLayout.getFontSize(context,
        baseSize: widget.isCompact ? 16.0 : 18.0);
    final iconSize = AppLayout.getIconSize(context,
        baseSize: widget.isCompact ? 20.0 : 24.0);
    final borderRadius = widget.isCompact
        ? AppLayout.buttonRadius * 0.8
        : AppLayout.buttonRadius;

    // Calculate margins to match note block spacing
    final horizontalMargin = widget.isCompact ? 8.0 : 12.0;
    final verticalMargin = widget.isCompact ? 6.0 : 8.0;

    // Don't apply margins if inline
    if (widget.isInline) {
      return _buildButtons(theme, buttonHeight, iconSize, borderRadius);
    }

    return Container(
      height: buttonHeight,
      margin: EdgeInsets.only(
        left: horizontalMargin + widget.indentationOffset,
        right: horizontalMargin,
        top: verticalMargin,
        bottom: verticalMargin,
      ),
      child: _buildButtons(theme, buttonHeight, iconSize, borderRadius),
    );
  }

  Widget _buildButtons(ThemeData theme, double buttonHeight, double iconSize,
      double borderRadius) {
    return Row(
      children: [
        // Plus button (left half)
        Expanded(
          child: Semantics(
            label: 'Add note block',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _handlePlusTap,
                onLongPress:
                    widget.canAddBlock ? widget.onAddIndentedBlock : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.canAddBlock
                        ? theme.colorScheme.primary.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: widget.canAddBlock
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: iconSize,
                      color: widget.canAddBlock
                          ? theme.colorScheme.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Minus button (right half)
        Expanded(
          child: Semantics(
            label: 'Remove note block',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.canRemoveBlock ? widget.onRemoveBlock : null,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                splashColor: widget.canRemoveBlock
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : null,
                highlightColor: widget.canRemoveBlock
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.canRemoveBlock
                        ? theme.colorScheme.primary.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: widget.canRemoveBlock
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.remove,
                      size: iconSize,
                      color: widget.canRemoveBlock
                          ? theme.colorScheme.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
