// widgets/tag/tag_page_toggle_button.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Tag page toggle button for switching between first and second tag pages
/// Light mode only
class TagPageToggleButton extends StatelessWidget {
  final VoidCallback onToggle;
  final int currentPage;
  final bool isCompact;

  const TagPageToggleButton({
    super.key,
    required this.onToggle,
    required this.currentPage,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate sizes based on compact mode
    final buttonSize = isCompact ? 32.0 : 40.0;
    final iconSize =
        AppLayout.getIconSize(context, baseSize: isCompact ? 18.0 : 22.0);
    final borderWidth = isCompact ? 1.5 : 2.0;
    final dotSize = isCompact ? 4.0 : 5.0; // Small, discreet dot size

    return Positioned(
      top: AppLayout.spacingS,
      right: AppLayout.spacingS,
      child: Semantics(
        label:
            currentPage == 0 ? 'Switch to tag page 2' : 'Switch to tag page 1',
        button: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The circular toggle button
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Light mode background only
                color: Colors.white.withOpacity(0.9),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(
                      0.3), // Make sure border uses primary color too
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: Tooltip(
                  message: currentPage == 0
                      ? 'Switch to tag page 2'
                      : 'Switch to tag page 1',
                  child: InkWell(
                    onTap: onToggle,
                    customBorder: const CircleBorder(),
                    splashColor: theme.colorScheme.primary.withOpacity(0.2),
                    highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          key: ValueKey(currentPage),
                          '${currentPage + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: iconSize * 0.9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Small spacing before dot
            SizedBox(height: isCompact ? 3.0 : 4.0),

            // Discreet dot indicator
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary
                    .withOpacity(0.6), // Same purple color as quick-tag dot
              ),
            ),
          ],
        ),
      ),
    );
  }
}
