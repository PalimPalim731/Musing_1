// lib/widgets/note/square_block_row.dart

import 'package:flutter/material.dart';
import '../../models/square_block_data.dart';
import '../../models/note_block_data.dart';
import 'square_block.dart';
import 'note_block_buttons.dart';

/// Row container for square blocks with inline +/- buttons
class SquareBlockRow extends StatelessWidget {
  final NoteBlockData noteBlockData;
  final bool isCompact;
  final VoidCallback? onAddSquareBlock;
  final VoidCallback? onAddNoteBlock;
  final VoidCallback? onAddIndentedNoteBlock;
  final VoidCallback? onRemoveBlock;
  final double totalWidth;

  const SquareBlockRow({
    super.key,
    required this.noteBlockData,
    this.isCompact = false,
    this.onAddSquareBlock,
    this.onAddNoteBlock,
    this.onAddIndentedNoteBlock,
    this.onRemoveBlock,
    required this.totalWidth,
  });

  @override
  Widget build(BuildContext context) {
    final squareBlocks = noteBlockData.squareBlocks;
    final blockCount = squareBlocks.length;
    final isFullRow = blockCount >= 3;

    // Calculate widths
    final squareBlockWidth = totalWidth / 3;
    final remainingWidth = totalWidth - (squareBlockWidth * blockCount);

    // Margins
    final horizontalMargin = isCompact ? 8.0 : 12.0;
    final verticalMargin = isCompact ? 6.0 : 8.0;
    final spacing = isCompact ? 4.0 : 6.0;
    final indentOffset =
        isCompact ? 16.0 : 20.0; // Indentation for medium blocks

    if (isFullRow) {
      // When row is full, show square blocks on top and buttons below
      return Column(
        children: [
          // Square blocks row
          Container(
            margin: EdgeInsets.only(
              left: horizontalMargin + indentOffset,
              right: horizontalMargin,
              top: verticalMargin,
              bottom: 0, // No bottom margin, buttons will handle their own
            ),
            child: Row(
              children: squareBlocks
                  .map((block) => Padding(
                        padding: EdgeInsets.only(right: spacing),
                        child: SquareBlock(
                          data: block,
                          isCompact: isCompact,
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Full-width +/- buttons below (like after a medium note block)
          NoteBlockButtons(
            onAddBlock: onAddNoteBlock, // Single tap creates normal block
            onAddIndentedBlock:
                onAddIndentedNoteBlock, // Long press creates indented block
            onRemoveBlock: onRemoveBlock,
            canAddBlock: true,
            canRemoveBlock: true,
            isCompact: isCompact,
            adaptiveHeight: null, // Use default height
            indentationOffset:
                indentOffset, // Same indentation as square blocks
            isInline: false,
            onDoublePress: null, // No double press when square blocks are full
          ),
        ],
      );
    } else {
      // When row is not full, show inline layout
      return Container(
        margin: EdgeInsets.only(
          left: horizontalMargin + indentOffset,
          right: horizontalMargin,
          top: verticalMargin,
          bottom: verticalMargin,
        ),
        child: Row(
          children: [
            // Square blocks
            ...squareBlocks.map((block) => Padding(
                  padding: EdgeInsets.only(right: spacing),
                  child: SquareBlock(
                    data: block,
                    isCompact: isCompact,
                  ),
                )),

            // Inline +/- buttons
            if (remainingWidth > 0)
              SizedBox(
                width: remainingWidth - spacing,
                child: NoteBlockButtons(
                  onAddBlock: onAddSquareBlock, // Single tap adds square block
                  onAddIndentedBlock:
                      onAddNoteBlock, // Long press creates medium block
                  onRemoveBlock: onRemoveBlock,
                  canAddBlock: blockCount < 3,
                  canRemoveBlock: true,
                  isCompact: isCompact,
                  adaptiveHeight:
                      isCompact ? 50.0 : 60.0, // Match square block height
                  indentationOffset: 0, // No additional indentation
                  isInline: true,
                  onDoublePress:
                      onAddIndentedNoteBlock, // Double press creates big block
                ),
              ),
          ],
        ),
      );
    }
  }
}
