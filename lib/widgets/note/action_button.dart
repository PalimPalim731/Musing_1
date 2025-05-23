// widgets/note/action_button.dart

import 'package:flutter/material.dart';

/// Action button for note input area
class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final String? tooltip;
  final Color? color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade700
        : Colors.grey.shade300);

    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: _buildButton(buttonColor),
          )
        : _buildButton(buttonColor);
  }

  Widget _buildButton(Color buttonColor) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: buttonColor,
      iconSize: iconSize,
      splashRadius: iconSize * 0.8, // More contained splash effect
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: iconSize * 1.5,
        minHeight: iconSize * 1.5,
      ),
      // Add ripple effect for better feedback
      splashColor: buttonColor.withOpacity(0.2),
      highlightColor: buttonColor.withOpacity(0.1),
    );
  }
}