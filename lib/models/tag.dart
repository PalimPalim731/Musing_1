// models/tag.dart

/// Data class for tag information
class TagData {
  final String id;
  final String label;
  final bool isSelected;

  const TagData({
    required this.id,
    required this.label,
    this.isSelected = false,
  });

  // Copy with method for immutability
  TagData copyWith({
    String? id,
    String? label,
    bool? isSelected,
  }) {
    return TagData(
      id: id ?? this.id,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Equality and hash code
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          isSelected == other.isSelected;

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ isSelected.hashCode;
  
  // For debugging
  @override
  String toString() => 'TagData(id: $id, label: $label, isSelected: $isSelected)';
}