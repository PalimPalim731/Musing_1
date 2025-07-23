// models/note_block_data.dart

import 'package:flutter/material.dart';
import 'square_block_data.dart';

/// Data structure to represent a note block with its controller, focus node, and indentation level
class NoteBlockData {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int indentLevel; // 0 = normal, 1+ = indented
  final List<SquareBlockData> squareBlocks; // NEW: Associated square blocks

  NoteBlockData({
    required this.controller,
    required this.focusNode,
    this.indentLevel = 0,
    List<SquareBlockData>? squareBlocks, // NEW
  }) : squareBlocks = squareBlocks ?? [];

  /// Create a copy with updated values
  NoteBlockData copyWith({
    TextEditingController? controller,
    FocusNode? focusNode,
    int? indentLevel,
    List<SquareBlockData>? squareBlocks, // NEW
  }) {
    return NoteBlockData(
      controller: controller ?? this.controller,
      focusNode: focusNode ?? this.focusNode,
      indentLevel: indentLevel ?? this.indentLevel,
      squareBlocks: squareBlocks ?? List.from(this.squareBlocks), // NEW
    );
  }

  /// Create a new note block with specified indentation
  factory NoteBlockData.withIndent(int indentLevel) {
    return NoteBlockData(
      controller: TextEditingController(),
      focusNode: FocusNode(),
      indentLevel: indentLevel,
    );
  }

  /// Create a normal (non-indented) note block
  factory NoteBlockData.normal() {
    return NoteBlockData(
      controller: TextEditingController(),
      focusNode: FocusNode(),
      indentLevel: 0,
    );
  }

  /// Check if this block is indented
  bool get isIndented => indentLevel > 0;

  /// Check if this block has square blocks
  bool get hasSquareBlocks => squareBlocks.isNotEmpty; // NEW

  /// Check if square blocks row is full (max 3)
  bool get isSquareBlockRowFull => squareBlocks.length >= 3; // NEW

  /// Dispose resources
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  String toString() =>
      'NoteBlockData(indentLevel: $indentLevel, hasText: ${controller.text.isNotEmpty}, squareBlocks: ${squareBlocks.length})';
}
