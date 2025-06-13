// widgets/quick_tag/quick_tag_page_toggle_button.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Quick-tag page toggle button for switching between first and second quick-tag pages
/// Light mode only
class QuickTagPageToggleButton extends StatelessWidget {
  final VoidCallback onToggle;
  final int currentPage;
  final bool isCompact;

  const QuickTagPageToggleButton({
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
    final lineLength = isCompact ? 7.5 : 9.4; // Length of the pointing line
    final lineWidth = isCompact ? 2.0 : 2.5; // Width of the line

    return Positioned(
      top: AppLayout.spacingS,
      left: AppLayout.spacingS,
      child: Semantics(
        label: currentPage == 0
            ? 'Switch to quick-tag page 2'
            : 'Switch to quick-tag page 1',
        button: true,
        child: Row(
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
                  color: theme.colorScheme.secondary
                      .withOpacity(0.3), // Use secondary color for quick-tags
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
                      ? 'Switch to quick-tag page 2'
                      : 'Switch to quick-tag page 1',
                  child: InkWell(
                    onTap: onToggle,
                    customBorder: const CircleBorder(),
                    splashColor: theme.colorScheme.secondary
                        .withOpacity(0.2), // Use secondary color for quick-tags
                    highlightColor:
                        theme.colorScheme.secondary.withOpacity(0.1),
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
                            color: theme.colorScheme
                                .secondary, // Use secondary color for quick-tags
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

            // Rightward pointing line
            Container(
              width: lineLength,
              height: lineWidth,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary
                    .withOpacity(0.4), // Use secondary color for quick-tags
                borderRadius: BorderRadius.circular(lineWidth / 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
