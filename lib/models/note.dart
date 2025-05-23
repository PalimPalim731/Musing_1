// models/note.dart

/// Note model representing a user's saved thought
class Note {
  final String id;
  final String content;
  final String category; // 'Private' or 'Public'
  final String size; // 'Large', 'Medium', or 'Small'
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tagIds;
  final Map<String, dynamic>? metadata; // For extensibility - future additions

  const Note({
    required this.id,
    required this.content,
    required this.category,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
    this.tagIds = const [],
    this.metadata,
  });

  // Factory constructor for creating a new Note
  factory Note.create({
    required String id,
    required String content,
    required String category,
    required String size,
    List<String> tagIds = const [],
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return Note(
      id: id,
      content: content,
      category: category,
      size: size,
      createdAt: now,
      updatedAt: now,
      tagIds: tagIds,
      metadata: metadata,
    );
  }

  // Copy with method for immutability
  Note copyWith({
    String? id,
    String? content,
    String? category,
    String? size,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tagIds,
    Map<String, dynamic>? metadata,
    bool clearMetadata = false,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagIds: tagIds ?? this.tagIds,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
    );
  }

  // Update method that automatically sets updatedAt
  Note update({
    String? content,
    String? category,
    String? size,
    List<String>? tagIds,
    Map<String, dynamic>? metadata,
    bool clearMetadata = false,
  }) {
    return copyWith(
      content: content,
      category: category,
      size: size,
      updatedAt: DateTime.now(),
      tagIds: tagIds,
      metadata: metadata,
      clearMetadata: clearMetadata,
    );
  }

  // From and to JSON methods for serialization
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      size: json['size'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tagIds: List<String>.from(json['tagIds'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tagIds': tagIds,
      'metadata': metadata,
    };
  }

  // Equality and hash code
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}