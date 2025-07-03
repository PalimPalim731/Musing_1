// models/note_block_data.dart

import 'package:flutter/material.dart';

/// Data structure to represent a note block with its controller, focus node, and indentation level
class NoteBlockData {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int indentLevel; // 0 = normal, 1+ = indented

  NoteBlockData({
    required this.controller,
    required this.focusNode,
    this.indentLevel = 0,
  });

  /// Create a copy with updated values
  NoteBlockData copyWith({
    TextEditingController? controller,
    FocusNode? focusNode,
    int? indentLevel,
  }) {
    return NoteBlockData(
      controller: controller ?? this.controller,
      focusNode: focusNode ?? this.focusNode,
      indentLevel: indentLevel ?? this.indentLevel,
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

  /// Dispose resources
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  String toString() =>
      'NoteBlockData(indentLevel: $indentLevel, hasText: ${controller.text.isNotEmpty})';
}
