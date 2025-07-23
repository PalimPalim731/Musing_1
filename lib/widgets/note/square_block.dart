// lib/widgets/note/square_block.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/square_block_data.dart';

/// Square block - A non-editable placeholder block (1/3 width of medium note block)
class SquareBlock extends StatelessWidget {
  final SquareBlockData data;
  final bool isCompact;
  final VoidCallback? onTap;

  const SquareBlock({
    super.key,
    required this.data,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Square dimensions based on 1/3 of medium block width
    final size = isCompact ? 50.0 : 60.0;
    final borderRadius =
        isCompact ? AppLayout.buttonRadius * 0.8 : AppLayout.buttonRadius;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: isCompact ? 1.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.crop_square,
              color: theme.colorScheme.primary.withOpacity(0.4),
              size: isCompact ? 20.0 : 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
