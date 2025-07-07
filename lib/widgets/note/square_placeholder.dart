// widgets/note/square_placeholder.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/note_element.dart';

/// A square placeholder widget that appears below indented note blocks
class SquarePlaceholder extends StatelessWidget {
  final SquareNoteElement element;
  final double width;
  final double height;
  final bool isCompact;
  final VoidCallback? onTap;

  const SquarePlaceholder({
    super.key,
    required this.element,
    required this.width,
    required this.height,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.8 : AppLayout.buttonRadius;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: element.backgroundColor ??
            theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: isCompact ? 1.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: isCompact ? 1.0 : 1.5,
            offset: Offset(0, isCompact ? 0.5 : 0.8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: theme.colorScheme.primary.withOpacity(0.15),
          highlightColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Center(
            child: element.placeholderText != null
                ? Text(
                    element.placeholderText!,
                    style: TextStyle(
                      color: theme.colorScheme.primary.withOpacity(0.6),
                      fontSize: isCompact ? 10.0 : 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Icon(
                    Icons.add_box_outlined,
                    size: isCompact ? 24.0 : 32.0,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                  ),
          ),
        ),
      ),
    );
  }
}
