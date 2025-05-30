// services/tag_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tag.dart';

/// Service for managing tags with support for two pages
class TagService {
  // Singleton pattern
  static final TagService _instance = TagService._internal();

  factory TagService() => _instance;

  TagService._internal() {
    // Initialize with default tags for both pages
    _tags.addAll(_defaultTagsPage1);
    _tags.addAll(_defaultTagsPage2);
  }

  // Maximum tag length constant
  static const int maxTagLength = 10;

  // Current active page (0 = first page, 1 = second page)
  int _currentPage = 0;

  // Default tags for page 1 (IDs 1-7)
  final List<TagData> _defaultTagsPage1 = [
    TagData(id: '1', label: 'Work'),
    TagData(id: '2', label: 'Ideas'),
    TagData(id: '3', label: 'Tasks'),
    TagData(id: '4', label: 'Personal'),
    TagData(id: '5', label: 'Travel'),
    TagData(id: '6', label: 'Health'),
    TagData(id: '7', label: 'Goals'),
  ];

  // Default tags for page 2 (IDs 8-14)
  final List<TagData> _defaultTagsPage2 = [
    TagData(id: '8', label: 'Family'),
    TagData(id: '9', label: 'Finance'),
    TagData(id: '10', label: 'Learning'),
    TagData(id: '11', label: 'Creative'),
    TagData(id: '12', label: 'Social'),
    TagData(id: '13', label: 'Shopping'),
    TagData(id: '14', label: 'Hobbies'),
  ];

  // In-memory storage for all tags - in a real app, this would be a database
  final List<TagData> _tags = [];

  // Stream controller for broadcasting tag changes
  final _tagsStreamController = StreamController<List<TagData>>.broadcast();

  // Stream controller for broadcasting page changes
  final _pageStreamController = StreamController<int>.broadcast();

  // Stream of tags for listening to changes
  Stream<List<TagData>> get tagsStream => _tagsStreamController.stream;

  // Stream of page changes for listening to page switches
  Stream<int> get pageStream => _pageStreamController.stream;

  // Get current page
  int get currentPage => _currentPage;

  // Toggle between pages
  void togglePage() {
    _currentPage = _currentPage == 0 ? 1 : 0;
    _notifyPageListeners();
    _notifyTagListeners(); // Also notify tag listeners since visible tags changed
  }

  // Set specific page
  void setPage(int page) {
    if (page >= 0 && page <= 1 && page != _currentPage) {
      _currentPage = page;
      _notifyPageListeners();
      _notifyTagListeners();
    }
  }

  // Utility method to truncate tag labels to max length
  String _truncateLabel(String label) {
    return label.length > maxTagLength
        ? label.substring(0, maxTagLength)
        : label;
  }

  // Get all tags (all 14 tags across both pages)
  List<TagData> getAllTags() {
    return List.unmodifiable(_tags);
  }

  // Get tags for the current page only (7 tags)
  List<TagData> getCurrentPageTags() {
    return getTagsForPage(_currentPage);
  }

  // Get tags for a specific page
  List<TagData> getTagsForPage(int page) {
    if (page == 0) {
      // Page 1: IDs 1-7
      return _tags.where((tag) {
        final id = int.tryParse(tag.id) ?? 0;
        return id >= 1 && id <= 7;
      }).toList();
    } else {
      // Page 2: IDs 8-14
      return _tags.where((tag) {
        final id = int.tryParse(tag.id) ?? 0;
        return id >= 8 && id <= 14;
      }).toList();
    }
  }

  // Get a tag by ID
  TagData? getTagById(String id) {
    try {
      return _tags.firstWhere((tag) => tag.id == id);
    } catch (e) {
      return null; // Tag not found
    }
  }

  // Add a new tag (will be added to the current page)
  Future<TagData> addTag(String label) async {
    // Truncate label to max length
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      throw ArgumentError('Tag label cannot be empty');
    }

    // Generate a unique ID - in a real app, this would be handled by the database
    // For now, find the highest ID and add 1
    int highestId = 0;
    for (var tag in _tags) {
      final id = int.tryParse(tag.id) ?? 0;
      if (id > highestId) highestId = id;
    }
    final newId = (highestId + 1).toString();

    final tag = TagData(id: newId, label: truncatedLabel);

    _tags.add(tag);
    _notifyTagListeners();

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
    _notifyTagListeners();

    return updatedTag;
  }

  // Delete a tag
  Future<bool> deleteTag(String id) async {
    // Don't allow deleting default tags
    if (_defaultTagsPage1.any((tag) => tag.id == id) ||
        _defaultTagsPage2.any((tag) => tag.id == id)) {
      return false;
    }

    final index = _tags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return false; // Tag not found
    }

    _tags.removeAt(index);
    _notifyTagListeners();

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
    _notifyTagListeners();

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
      _notifyTagListeners();
    }
  }

  // Reset to default tags
  Future<void> resetToDefaults() async {
    _tags.clear();
    _tags.addAll(_defaultTagsPage1);
    _tags.addAll(_defaultTagsPage2);
    _currentPage = 0; // Reset to first page
    _notifyTagListeners();
    _notifyPageListeners();
  }

  // Notify tag listeners of changes
  void _notifyTagListeners() {
    if (!_tagsStreamController.isClosed) {
      // Send only the current page's tags to the UI
      _tagsStreamController.add(List.unmodifiable(getCurrentPageTags()));
    }
  }

  // Notify page listeners of changes
  void _notifyPageListeners() {
    if (!_pageStreamController.isClosed) {
      _pageStreamController.add(_currentPage);
    }
  }

  // Dispose resources
  void dispose() {
    _tagsStreamController.close();
    _pageStreamController.close();
  }
}
