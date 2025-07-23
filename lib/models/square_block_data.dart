// lib/models/square_block_data.dart

import 'package:flutter/material.dart';

/// Data structure to represent a square block (non-editable placeholder)
class SquareBlockData {
  final String id;
  final int position; // Position in the row (0, 1, or 2)

  SquareBlockData({
    required this.id,
    required this.position,
  });

  /// Create a new square block with a unique ID
  factory SquareBlockData.create(int position) {
    return SquareBlockData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: position,
    );
  }

  @override
  String toString() => 'SquareBlockData(id: $id, position: $position)';
}
