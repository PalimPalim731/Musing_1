// widgets/note/note_block_buttons.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Plus and minus buttons for adding/removing note blocks
class NoteBlockButtons extends StatelessWidget {
  final VoidCallback? onAddBlock;
  final VoidCallback? onRemoveBlock;
  final bool canRemoveBlock; // Whether removal is allowed
  final bool isCompact;

  const NoteBlockButtons({
    super.key,
    this.onAddBlock,
    this.onRemoveBlock,
    this.canRemoveBlock = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonHeight = isCompact ? 35.0 : 40.0;
    final fontSize =
        AppLayout.getFontSize(context, baseSize: isCompact ? 16.0 : 18.0);
    final iconSize =
        AppLayout.getIconSize(context, baseSize: isCompact ? 20.0 : 24.0);
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.8 : AppLayout.buttonRadius;

    return Container(
      height: buttonHeight,
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 12.0,
        vertical: isCompact ? 6.0 : 8.0,
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
                child: InkWell(
                  onTap: onAddBlock,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                  ),
                  splashColor: theme.colorScheme.primary.withOpacity(0.15),
                  highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
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
                        color: theme.colorScheme.primary,
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
