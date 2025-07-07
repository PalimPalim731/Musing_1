// widgets/note/square_with_buttons.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/note_element.dart';
import 'square_placeholder.dart';
import 'note_block_buttons.dart';

/// Combined widget that shows a square (1/3 width) and note block buttons (2/3 width)
/// positioned horizontally below an indented note block
class SquareWithButtons extends StatelessWidget {
  final SquareNoteElement squareElement;
  final double totalHeight;
  final bool isCompact;
  final double indentationOffset;

  // Button callbacks
  final VoidCallback? onAddBlock;
  final VoidCallback? onAddIndentedBlock;
  final VoidCallback? onAddSquare;
  final VoidCallback? onRemoveBlock;
  final VoidCallback? onRemoveSquare; // New callback for removing the square
  final bool canRemoveBlock;
  final bool canAddBlock;

  // Square callbacks
  final VoidCallback? onSquareTap;

  const SquareWithButtons({
    super.key,
    required this.squareElement,
    required this.totalHeight,
    this.isCompact = false,
    this.indentationOffset = 0.0,
    this.onAddBlock,
    this.onAddIndentedBlock,
    this.onAddSquare,
    this.onRemoveBlock,
    this.onRemoveSquare,
    this.canRemoveBlock = true,
    this.canAddBlock = true,
    this.onSquareTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate margins to match note block spacing and apply indentation
    final horizontalMargin = isCompact ? 8.0 : 12.0;
    final verticalMargin = isCompact ? 6.0 : 8.0;
    final spacing = isCompact ? AppLayout.spacingXS : AppLayout.spacingS;

    return Container(
      height: totalHeight,
      margin: EdgeInsets.only(
        left: horizontalMargin + indentationOffset,
        right: horizontalMargin,
        top: verticalMargin,
        bottom: verticalMargin,
      ),
      child: Row(
        children: [
          // Square placeholder (1/3 of the width)
          Expanded(
            flex: 1,
            child: SquarePlaceholder(
              element: squareElement,
              width: double.infinity, // Will be constrained by Expanded
              height: totalHeight,
              isCompact: isCompact,
              onTap: onSquareTap,
            ),
          ),

          // Small spacing between square and buttons
          SizedBox(width: spacing),

          // Note block buttons (2/3 of the remaining width)
          Expanded(
            flex: 2,
            child: _buildButtonsOnly(),
          ),
        ],
      ),
    );
  }

  /// Build just the buttons part without the container wrapper
  Widget _buildButtonsOnly() {
    final theme = ThemeData.light(); // Get theme context
    final fontSize = isCompact ? 16.0 : 18.0;
    final iconSize = isCompact ? 20.0 : 24.0;
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.8 : AppLayout.buttonRadius;

    return Row(
      children: [
        // Plus button (left half of buttons area)
        Expanded(
          child: Semantics(
            label: 'Add note block',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: canAddBlock ? onAddBlock : null,
                onLongPress: canAddBlock
                    ? onAddIndentedBlock
                    : null, // Still create indented blocks
                child: Container(
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: canAddBlock
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: canAddBlock
                          ? Colors.blue.withOpacity(0.2)
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
                      color: canAddBlock ? Colors.blue : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Minus button (right half of buttons area) - can remove square or blocks
        Expanded(
          child: Semantics(
            label: 'Remove element',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // If we can remove the square, prioritize that, otherwise remove block
                  if (onRemoveSquare != null) {
                    onRemoveSquare!();
                  } else if (canRemoveBlock && onRemoveBlock != null) {
                    onRemoveBlock!();
                  }
                },
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                splashColor: (onRemoveSquare != null || canRemoveBlock)
                    ? Colors.blue.withOpacity(0.15)
                    : null,
                highlightColor: (onRemoveSquare != null || canRemoveBlock)
                    ? Colors.blue.withOpacity(0.1)
                    : null,
                child: Container(
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: (onRemoveSquare != null || canRemoveBlock)
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: (onRemoveSquare != null || canRemoveBlock)
                          ? Colors.blue.withOpacity(0.2)
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
                      color: (onRemoveSquare != null || canRemoveBlock)
                          ? Colors.blue
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
