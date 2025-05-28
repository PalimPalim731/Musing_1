// widgets/theme/theme_toggle_button.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Theme toggle button for switching between light and dark modes
class ThemeToggleButton extends StatelessWidget {
  final VoidCallback onToggle;
  final ThemeMode currentThemeMode;
  final bool isCompact;

  const ThemeToggleButton({
    super.key,
    required this.onToggle,
    required this.currentThemeMode,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = _isDarkMode(context);

    // Calculate sizes based on compact mode
    final buttonSize = isCompact ? 32.0 : 40.0;
    final iconSize =
        AppLayout.getIconSize(context, baseSize: isCompact ? 18.0 : 22.0);
    final borderWidth = isCompact ? 1.5 : 2.0;

    return Positioned(
      top: AppLayout.spacingS,
      left: AppLayout.spacingS,
      child: Semantics(
        label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        button: true,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.brightness == Brightness.light
                ? Colors.white.withOpacity(0.9)
                : const Color(0xFF2A2A2A).withOpacity(0.9),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
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
              message:
                  isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
              child: InkWell(
                onTap: onToggle,
                customBorder: const CircleBorder(),
                splashColor: theme.colorScheme.primary.withOpacity(0.2),
                highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      key: ValueKey(isDarkMode),
                      color: theme.colorScheme.primary,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to determine if dark mode is currently active
  bool _isDarkMode(BuildContext context) {
    if (currentThemeMode == ThemeMode.dark) return true;
    if (currentThemeMode == ThemeMode.light) return false;

    // For system mode, check the current brightness
    return Theme.of(context).brightness == Brightness.dark;
  }
}
