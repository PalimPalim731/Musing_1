// widgets/note/note_block_buttons.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Plus and minus buttons for adding/removing note blocks
/// Height is fixed at 50% of the default note block size
/// Width adapts to match indentation of the latest note block
class NoteBlockButtons extends StatelessWidget {
  final VoidCallback? onAddBlock;
  final VoidCallback? onAddIndentedBlock; // Callback for indented block
  final VoidCallback? onAddSquare; // New callback for square creation
  final VoidCallback? onRemoveBlock;
  final bool canRemoveBlock; // Whether removal is allowed
  final bool canAddBlock; // Whether adding more blocks is allowed
  final bool isCompact;
  final double? adaptiveHeight; // Fixed height (50% of default note block size)
  final double indentationOffset; // Indentation to match latest note block
  final bool
      isAfterIndentedBlock; // Whether buttons are positioned after an indented block

  const NoteBlockButtons({
    super.key,
    this.onAddBlock,
    this.onAddIndentedBlock,
    this.onAddSquare,
    this.onRemoveBlock,
    this.canRemoveBlock = true,
    this.canAddBlock = true, // Default to allowing add
    this.isCompact = false,
    this.adaptiveHeight, // Fixed height (50% of default note block size)
    this.indentationOffset = 0.0, // Default to no indentation
    this.isAfterIndentedBlock = false, // Default to not after indented block
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use fixed height (50% of default note block) if provided, otherwise fall back to default sizing
    final buttonHeight = adaptiveHeight ?? (isCompact ? 35.0 : 40.0);

    final fontSize =
        AppLayout.getFontSize(context, baseSize: isCompact ? 16.0 : 18.0);
    final iconSize =
        AppLayout.getIconSize(context, baseSize: isCompact ? 20.0 : 24.0);
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.8 : AppLayout.buttonRadius;

    // Calculate margins to match note block spacing and apply indentation
    final horizontalMargin = isCompact ? 8.0 : 12.0;
    final verticalMargin = isCompact ? 6.0 : 8.0;

    return Container(
      height: buttonHeight,
      margin: EdgeInsets.only(
        left: horizontalMargin +
            indentationOffset, // Apply indentation to match latest note block
        right: horizontalMargin,
        top: verticalMargin,
        bottom: verticalMargin,
      ),
      child: Row(
        children: [
          // Plus button (left half)
          Expanded(
            child: Semantics(
              label: 'Add note block',
              button: true,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: canAddBlock ? onAddBlock : null,
                  onLongPress: canAddBlock
                      ? (isAfterIndentedBlock
                          ? onAddSquare
                          : onAddIndentedBlock)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: canAddBlock
                          ? theme.colorScheme.primary.withOpacity(0.05)
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

          // Minus button (right half)
          Expanded(
            child: Semantics(
              label: 'Remove note block',
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canRemoveBlock ? onRemoveBlock : null,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius),
                  ),
                  splashColor: canRemoveBlock
                      ? theme.colorScheme.primary.withOpacity(0.15)
                      : null,
                  highlightColor: canRemoveBlock
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: canRemoveBlock
                          ? theme.colorScheme.primary.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.03),
                      border: Border.all(
                        color: canRemoveBlock
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
                        color: canRemoveBlock
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
      ),
    );
  }
}
