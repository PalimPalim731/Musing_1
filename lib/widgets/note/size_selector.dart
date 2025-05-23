// widgets/note/size_selector.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';

/// Size selector widget
class SizeSelector extends StatelessWidget {
  final String selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    const sizeOptions = ['Large', 'Medium', 'Small'];
    final theme = Theme.of(context);
    final isCompact = MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    final height = isCompact ? AppLayout.selectorHeight * 0.9 : AppLayout.selectorHeight;
    final padding = isCompact ? AppLayout.spacingS * 0.7 : AppLayout.spacingS;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2), // Circular shape
              border: Border.all(color: theme.colorScheme.primary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < sizeOptions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  SizeOption(
                    text: sizeOptions[i],
                    isSelected: selectedSize == sizeOptions[i],
                    onTap: () => onSizeSelected(sizeOptions[i]),
                    width: isCompact ? 75 : 85,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual size option button
class SizeOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const SizeOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.width = 85,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = AppLayout.getFontSize(context);

    return Semantics(
      label: '$text size',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: isSelected ? BorderRadius.circular(25) : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}