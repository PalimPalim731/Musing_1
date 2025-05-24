// services/tag_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tag.dart';

/// Service for managing tags
class TagService {
  // Singleton pattern
  static final TagService _instance = TagService._internal();

  factory TagService() => _instance;

  TagService._internal() {
    // Initialize with default tags
    _tags.addAll(_defaultTags);
  }

  // Maximum tag length constant
  static const int maxTagLength = 7;

  // Default tags - all within 7 character limit (now 7 total tags)
  final List<TagData> _defaultTags = [
    TagData(id: '1', label: 'Work'),
    TagData(id: '2', label: 'Ideas'),
    TagData(id: '3', label: 'Tasks'),
    TagData(
        id: '4',
        label: 'Personal'), // This will be truncated to "Person" when edited
    TagData(id: '5', label: 'Travel'),
    TagData(id: '6', label: 'Health'),
    TagData(id: '7', label: 'Goals'),
  ];

  // In-memory storage for tags - in a real app, this would be a database
  final List<TagData> _tags = [];

  // Stream controller for broadcasting tag changes
  final _tagsStreamController = StreamController<List<TagData>>.broadcast();

  // Stream of tags for listening to changes
  Stream<List<TagData>> get tagsStream => _tagsStreamController.stream;

  // Utility method to truncate tag labels to max length
  String _truncateLabel(String label) {
    return label.length > maxTagLength
        ? label.substring(0, maxTagLength)
        : label;
  }

  // Get all tags
  List<TagData> getAllTags() {
    return List.unmodifiable(_tags);
  }

  // Get a tag by ID
  TagData? getTagById(String id) {
    try {
      return _tags.firstWhere((tag) => tag.id == id);
    } catch (e) {
      return null; // Tag not found
    }
  }

  // Add a new tag
  Future<TagData> addTag(String label) async {
    // Truncate label to max length
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      throw ArgumentError('Tag label cannot be empty');
    }

    // Generate a unique ID - in a real app, this would be handled by the database
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final tag = TagData(id: id, label: truncatedLabel);

    _tags.add(tag);
    _notifyListeners();

    return tag;
  }

  // Update a tag
  Future<TagData?> updateTag(String id, String label) async {
    final index = _tags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return null; // Tag not found
    }

    // Truncate label to max length
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      debugPrint('Tag label cannot be empty. Keeping original name.');
      return _tags[index];
    }

    // Don't update if the label is the same
    if (_tags[index].label == truncatedLabel) {
      return _tags[index];
    }

    // Ensure we're not creating a duplicate
    if (_tags.any((t) =>
        t.id != id && t.label.toLowerCase() == truncatedLabel.toLowerCase())) {
      // In a real app, you'd want to handle this more gracefully,
      // perhaps by showing a message to the user
      debugPrint('Tag $truncatedLabel already exists. Using original name.');
      return _tags[index];
    }

    final updatedTag = _tags[index].copyWith(label: truncatedLabel);
    _tags[index] = updatedTag;
    _notifyListeners();

    return updatedTag;
  }

  // Delete a tag
  Future<bool> deleteTag(String id) async {
    // Don't allow deleting default tags
    if (_defaultTags.any((tag) => tag.id == id)) {
      return false;
    }

    final index = _tags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return false; // Tag not found
    }

    _tags.removeAt(index);
    _notifyListeners();

    return true;
  }

  // Toggle tag selection
  Future<TagData?> toggleTagSelection(String id) async {
    final index = _tags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return null; // Tag not found
    }

    final tag = _tags[index];
    final updatedTag = tag.copyWith(isSelected: !tag.isSelected);

    _tags[index] = updatedTag;
    _notifyListeners();

    return updatedTag;
  }

  // Reset tag selections
  Future<void> resetTagSelections() async {
    bool changed = false;

    for (int i = 0; i < _tags.length; i++) {
      if (_tags[i].isSelected) {
        _tags[i] = _tags[i].copyWith(isSelected: false);
        changed = true;
      }
    }

    if (changed) {
      _notifyListeners();
    }
  }

  // Reset to default tags
  Future<void> resetToDefaults() async {
    _tags.clear();
    _tags.addAll(_defaultTags);
    _notifyListeners();
  }

  // Notify listeners of changes
  void _notifyListeners() {
    if (!_tagsStreamController.isClosed) {
      _tagsStreamController.add(List.unmodifiable(_tags));
    }
  }

  // Dispose resources
  void dispose() {
    _tagsStreamController.close();
  }
}
