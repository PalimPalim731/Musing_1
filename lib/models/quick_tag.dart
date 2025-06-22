// models/quick_tag.dart

/// Data class for quick tag information (legacy - use TagData instead)
class QuickTagData {
  final String id;
  final String label;
  final bool isSelected;

  const QuickTagData({
    required this.id,
    required this.label,
    this.isSelected = false,
  });

  // Copy with method for immutability
  QuickTagData copyWith({
    String? id,
    String? label,
    bool? isSelected,
  }) {
    return QuickTagData(
      id: id ?? this.id,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Equality and hash code
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickTagData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          isSelected == other.isSelected;

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ isSelected.hashCode;

  // For debugging
  @override
  String toString() =>
      'QuickTagData(id: $id, label: $label, isSelected: $isSelected)';
}
