// models/note_element.dart

import 'package:flutter/material.dart';

/// Abstract base class for different types of note elements
abstract class NoteElement {
  final String id;
  final int indentLevel;

  NoteElement({
    required this.id,
    this.indentLevel = 0,
  });

  /// Dispose resources if needed
  void dispose() {}

  /// Check if this element is indented
  bool get isIndented => indentLevel > 0;
}

/// Text-based note block element
class TextNoteElement extends NoteElement {
  final TextEditingController controller;
  final FocusNode focusNode;

  TextNoteElement({
    required String id,
    required this.controller,
    required this.focusNode,
    int indentLevel = 0,
  }) : super(id: id, indentLevel: indentLevel);

  /// Create a new text note element with specified indentation
  factory TextNoteElement.withIndent(String id, int indentLevel) {
    return TextNoteElement(
      id: id,
      controller: TextEditingController(),
      focusNode: FocusNode(),
      indentLevel: indentLevel,
    );
  }

  /// Create a normal (non-indented) text note element
  factory TextNoteElement.normal(String id) {
    return TextNoteElement(
      id: id,
      controller: TextEditingController(),
      focusNode: FocusNode(),
      indentLevel: 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  String toString() =>
      'TextNoteElement(id: $id, indentLevel: $indentLevel, hasText: ${controller.text.isNotEmpty})';
}

/// Square placeholder element
class SquareNoteElement extends NoteElement {
  final Color? backgroundColor;
  final String? placeholderText;

  SquareNoteElement({
    required String id,
    int indentLevel = 0,
    this.backgroundColor,
    this.placeholderText,
  }) : super(id: id, indentLevel: indentLevel);

  /// Create a square element positioned after an indented block
  factory SquareNoteElement.afterIndented(String id, int indentLevel) {
    return SquareNoteElement(
      id: id,
      indentLevel: indentLevel,
      placeholderText: 'Square placeholder',
    );
  }

  @override
  String toString() =>
      'SquareNoteElement(id: $id, indentLevel: $indentLevel, placeholder: $placeholderText)';
}
