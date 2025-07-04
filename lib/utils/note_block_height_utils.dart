// utils/note_block_height_utils.dart

import 'package:flutter/material.dart';

/// Utility functions for calculating note block heights consistently
class NoteBlockHeightUtils {
  // Private constructor to prevent instantiation
  NoteBlockHeightUtils._();

  // Constants for note block calculations
  static const int maxCharacters = 100;
  static const int averageCharsPerLine = 45; // Estimated characters per line

  /// Calculate responsive dimensions based on compact mode and indentation
  static ({
    double baseHeight,
    double lineHeight,
    double padding,
    double margin,
    double indentOffset
  }) getDimensions(BuildContext context, {bool isCompact = false, int indentLevel = 0}) {
    // Base indentation per level
    final baseIndent = isCompact ? 16.0 : 20.0;
    final indentOffset = indentLevel * baseIndent;

    if (isCompact) {
      return (
        baseHeight: 60.0, // Reduced from 120.0 to double the header size
        lineHeight: 18.0,
        padding: 12.0,
        margin: 8.0,
        indentOffset: indentOffset,
      );
    } else {
      return (
        baseHeight: 70.0, // Reduced from 150.0 to double the header size
        lineHeight: 22.0,
        padding: 16.0,
        margin: 12.0,
        indentOffset: indentOffset,
      );
    }
  }

  /// Calculate dynamic height based on text content
  static double calculateDynamicHeight(
    BuildContext context,
    String text, {
    bool isCompact = false,
    int indentLevel = 0,
  }) {
    final dimensions = getDimensions(context, isCompact: isCompact, indentLevel: indentLevel);

    if (text.isEmpty) {
      return dimensions.baseHeight;
    }

    // Calculate approximate number of lines based on character count and actual line breaks
    final manualLineBreaks = '\n'.allMatches(text).length;
    final estimatedWrappedLines = (text.length / averageCharsPerLine).ceil();
    final totalLines = manualLineBreaks + estimatedWrappedLines;

    // Ensure at least 1 line
    final lines = totalLines < 1 ? 1 : totalLines;

    // Calculate height: base height + additional lines
    final additionalHeight = (lines - 1) * dimensions.lineHeight;
    return dimensions.baseHeight + additionalHeight;
  }

  /// Calculate the minimum height for note block buttons (based on empty note block)
  static double calculateMinimumHeight(BuildContext context, {bool isCompact = false}) {
    return calculateDynamicHeight(context, '', isCompact: isCompact);
  }
}