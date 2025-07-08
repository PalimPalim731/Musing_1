// widgets/note/square_with_buttons.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/note_element.dart';
import 'square_placeholder.dart';
import 'note_block_buttons.dart';

/// Combined widget that shows multiple squares with dynamic layout:
/// - 1-2 squares: Horizontal layout with compact buttons to the right
/// - 3 squares: Horizontal squares + full-size buttons below
class MultiSquareWithButtons extends StatelessWidget {
  final List<SquareNoteElement> squareElements;
  final double totalHeight;
  final bool isCompact;
  final double indentationOffset;

  // Button callbacks
  final VoidCallback? onAddBlock;
  final VoidCallback? onAddIndentedBlock;
  final VoidCallback? onAddSquare; // For adding more squares (up to 3)
  final VoidCallback? onRemoveBlock;
  final VoidCallback? onRemoveSquare; // For removing the most recent square
  final bool canRemoveBlock;
  final bool canAddBlock;

  // Square callbacks
  final Function(SquareNoteElement)? onSquareTap;

  const MultiSquareWithButtons({
    super.key,
    required this.squareElements,
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
    final squareCount = squareElements.length;

    // Dynamic layout based on square count
    if (squareCount <= 2) {
      // Horizontal layout: squares + compact buttons to the right
      return _buildHorizontalLayout(context);
    } else {
      // Vertical layout: squares on top row + full buttons below
      return _buildVerticalLayout(context);
    }
  }

  /// Build horizontal layout for 1-2 squares
  Widget _buildHorizontalLayout(BuildContext context) {
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
          // Squares (distributed evenly)
          ...squareElements
              .asMap()
              .entries
              .map((entry) {
                final square = entry.value;
                return [
                  // Add spacing before square (except for first)
                  if (entry.key > 0) SizedBox(width: spacing),

                  // Square placeholder
                  Expanded(
                    child: SquarePlaceholder(
                      element: square,
                      width: double.infinity,
                      height: totalHeight,
                      isCompact: isCompact,
                      onTap: () => onSquareTap?.call(square),
                    ),
                  ),
                ];
              })
              .expand((widgets) => widgets)
              .toList(),

          // Spacing before buttons
          SizedBox(width: spacing),

          // Compact buttons (fixed width based on square count)
          SizedBox(
            width: _getCompactButtonWidth(),
            child: _buildCompactButtons(context),
          ),
        ],
      ),
    );
  }

  /// Build vertical layout for 3 squares
  Widget _buildVerticalLayout(BuildContext context) {
    final horizontalMargin = isCompact ? 8.0 : 12.0;
    final verticalMargin = isCompact ? 6.0 : 8.0;
    final spacing = isCompact ? AppLayout.spacingXS : AppLayout.spacingS;

    return Container(
      margin: EdgeInsets.only(
        left: horizontalMargin + indentationOffset,
        right: horizontalMargin,
        top: verticalMargin,
        bottom: verticalMargin,
      ),
      child: Column(
        children: [
          // Top row: 3 squares horizontally
          SizedBox(
            height: totalHeight,
            child: Row(
              children: squareElements
                  .asMap()
                  .entries
                  .map((entry) {
                    final square = entry.value;
                    return [
                      // Add spacing before square (except for first)
                      if (entry.key > 0) SizedBox(width: spacing),

                      // Square placeholder
                      Expanded(
                        child: SquarePlaceholder(
                          element: square,
                          width: double.infinity,
                          height: totalHeight,
                          isCompact: isCompact,
                          onTap: () => onSquareTap?.call(square),
                        ),
                      ),
                    ];
                  })
                  .expand((widgets) => widgets)
                  .toList(),
            ),
          ),

          // Spacing between squares and buttons
          SizedBox(height: spacing),

          // Bottom row: Full-size buttons
          SizedBox(
            height: totalHeight,
            child: _buildFullButtons(context),
          ),
        ],
      ),
    );
  }

  /// Get width for compact buttons based on square count
  double _getCompactButtonWidth() {
    if (squareElements.length == 1) {
      return isCompact ? 80.0 : 100.0; // More space when only 1 square
    } else {
      return isCompact ? 60.0 : 80.0; // Less space when 2 squares
    }
  }

  /// Build compact buttons for horizontal layout (1-2 squares)
  Widget _buildCompactButtons(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = isCompact ? 16.0 : 20.0; // Smaller icons for compact mode
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.7 : AppLayout.buttonRadius * 0.8;

    return Row(
      children: [
        // Compact Plus button
        Expanded(
          child: Semantics(
            label: squareElements.length < 3 ? 'Add square' : 'Add note block',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  // Priority: Add square if under limit, otherwise add block
                  if (squareElements.length < 3 && onAddSquare != null) {
                    onAddSquare!();
                  } else if (canAddBlock && onAddBlock != null) {
                    onAddBlock!();
                  }
                },
                onLongPress: canAddBlock ? onAddIndentedBlock : null,
                child: Container(
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: (squareElements.length < 3 || canAddBlock)
                        ? theme.colorScheme.secondary.withOpacity(
                            0.08) // Different color for square mode
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: (squareElements.length < 3 || canAddBlock)
                          ? theme.colorScheme.secondary.withOpacity(0.25)
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
                      color: (squareElements.length < 3 || canAddBlock)
                          ? theme.colorScheme.secondary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Compact Minus button
        Expanded(
          child: Semantics(
            label: 'Remove element',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Priority: Remove square if squares exist, otherwise remove block
                  if (squareElements.isNotEmpty && onRemoveSquare != null) {
                    onRemoveSquare!();
                  } else if (canRemoveBlock && onRemoveBlock != null) {
                    onRemoveBlock!();
                  }
                },
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                splashColor: (squareElements.isNotEmpty || canRemoveBlock)
                    ? theme.colorScheme.secondary.withOpacity(0.15)
                    : null,
                highlightColor: (squareElements.isNotEmpty || canRemoveBlock)
                    ? theme.colorScheme.secondary.withOpacity(0.1)
                    : null,
                child: Container(
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: (squareElements.isNotEmpty || canRemoveBlock)
                        ? theme.colorScheme.secondary.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: (squareElements.isNotEmpty || canRemoveBlock)
                          ? theme.colorScheme.secondary.withOpacity(0.25)
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
                      color: (squareElements.isNotEmpty || canRemoveBlock)
                          ? theme.colorScheme.secondary
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

  /// Build full-size buttons for vertical layout (3 squares)
  Widget _buildFullButtons(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = isCompact ? 20.0 : 24.0; // Normal icon size
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.8 : AppLayout.buttonRadius;

    return Row(
      children: [
        // Full Plus button (back to normal note block adding)
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
                    : null, // Long press for indented blocks
                child: Container(
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: canAddBlock
                        ? theme.colorScheme.primary
                            .withOpacity(0.05) // Back to primary color
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: canAddBlock
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
                      color: canAddBlock
                          ? theme.colorScheme.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Full Minus button (removes squares first, then blocks)
        Expanded(
          child: Semantics(
            label: 'Remove element',
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Priority: Remove square if squares exist, otherwise remove block
                  if (squareElements.isNotEmpty && onRemoveSquare != null) {
                    onRemoveSquare!();
                  } else if (canRemoveBlock && onRemoveBlock != null) {
                    onRemoveBlock!();
                  }
                },
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                splashColor: (squareElements.isNotEmpty || canRemoveBlock)
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : null,
                highlightColor: (squareElements.isNotEmpty || canRemoveBlock)
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : null,
                child: Container(
                  height: totalHeight,
                  decoration: BoxDecoration(
                    color: (squareElements.isNotEmpty || canRemoveBlock)
                        ? theme.colorScheme.primary.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.03),
                    border: Border.all(
                      color: (squareElements.isNotEmpty || canRemoveBlock)
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
                      color: (squareElements.isNotEmpty || canRemoveBlock)
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

/// Legacy widget for backward compatibility (single square)
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
  final VoidCallback? onRemoveSquare;
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
    // Delegate to the new multi-square widget with a single square
    return MultiSquareWithButtons(
      squareElements: [squareElement],
      totalHeight: totalHeight,
      isCompact: isCompact,
      indentationOffset: indentationOffset,
      onAddBlock: onAddBlock,
      onAddIndentedBlock: onAddIndentedBlock,
      onAddSquare: onAddSquare,
      onRemoveBlock: onRemoveBlock,
      onRemoveSquare: onRemoveSquare,
      canRemoveBlock: canRemoveBlock,
      canAddBlock: canAddBlock,
      onSquareTap: onSquareTap != null ? (_) => onSquareTap!() : null,
    );
  }
}
