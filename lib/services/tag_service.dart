// services/tag_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tag.dart';

/// Service for managing tags with support for category-specific tag sets
class TagService {
  // Singleton pattern
  static final TagService _instance = TagService._internal();

  factory TagService() => _instance;

  TagService._internal() {
    // Initialize with default tags for all categories
    _initializeDefaultTags();
    // Start with Private category
    _currentCategory = 'Private';
  }

  // Maximum tag length constant
  static const int maxTagLength = 10;

  // Current active page (0 = first page, 1 = second page)
  int _currentPage = 0;

  // Current active category
  String _currentCategory = 'Private';

  // Default tags for Private category - Page 1 (IDs 1-7)
  final List<TagData> _defaultPrivatePage1 = [
    TagData(id: '1', label: 'Work'),
    TagData(id: '2', label: 'Ideas'),
    TagData(id: '3', label: 'Tasks'),
    TagData(id: '4', label: 'Personal'),
    TagData(id: '5', label: 'Travel'),
    TagData(id: '6', label: 'Health'),
    TagData(id: '7', label: 'Goals'),
  ];

  // Default tags for Private category - Page 2 (IDs 8-14)
  final List<TagData> _defaultPrivatePage2 = [
    TagData(id: '8', label: 'Family'),
    TagData(id: '9', label: 'Finance'),
    TagData(id: '10', label: 'Learning'),
    TagData(id: '11', label: 'Creative'),
    TagData(id: '12', label: 'Social'),
    TagData(id: '13', label: 'Shopping'),
    TagData(id: '14', label: 'Hobbies'),
  ];

  // Default tags for Circle category - Page 1 (IDs 15-21)
  final List<TagData> _defaultCirclePage1 = [
    TagData(id: '15', label: 'Friends'),
    TagData(id: '16', label: 'Events'),
    TagData(id: '17', label: 'Plans'),
    TagData(id: '18', label: 'Memories'),
    TagData(id: '19', label: 'Photos'),
    TagData(id: '20', label: 'Stories'),
    TagData(id: '21', label: 'Updates'),
  ];

  // Default tags for Circle category - Page 2 (IDs 22-28)
  final List<TagData> _defaultCirclePage2 = [
    TagData(id: '22', label: 'Group'),
    TagData(id: '23', label: 'Chat'),
    TagData(id: '24', label: 'Meet'),
    TagData(id: '25', label: 'Share'),
    TagData(id: '26', label: 'Discuss'),
    TagData(id: '27', label: 'Invite'),
    TagData(id: '28', label: 'Connect'),
  ];

  // Default tags for Public category - Page 1 (IDs 29-35)
  final List<TagData> _defaultPublicPage1 = [
    TagData(id: '29', label: 'Blog'),
    TagData(id: '30', label: 'Article'),
    TagData(id: '31', label: 'Opinion'),
    TagData(id: '32', label: 'News'),
    TagData(id: '33', label: 'Review'),
    TagData(id: '34', label: 'Tutorial'),
    TagData(id: '35', label: 'Guide'),
  ];

  // Default tags for Public category - Page 2 (IDs 36-42)
  final List<TagData> _defaultPublicPage2 = [
    TagData(id: '36', label: 'Announce'),
    TagData(id: '37', label: 'Promote'),
    TagData(id: '38', label: 'Launch'),
    TagData(id: '39', label: 'Release'),
    TagData(id: '40', label: 'Update'),
    TagData(id: '41', label: 'Feature'),
    TagData(id: '42', label: 'Content'),
  ];

  // Storage for all tags organized by category
  final Map<String, List<TagData>> _categoryTags = {
    'Private': [],
    'Circle': [],
    'Public': [],
  };

  // Stream controller for broadcasting tag changes
  final _tagsStreamController = StreamController<List<TagData>>.broadcast();

  // Stream controller for broadcasting page changes
  final _pageStreamController = StreamController<int>.broadcast();

  // Stream controller for broadcasting category changes
  final _categoryStreamController = StreamController<String>.broadcast();

  // Stream of tags for listening to changes
  Stream<List<TagData>> get tagsStream => _tagsStreamController.stream;

  // Stream of page changes for listening to page switches
  Stream<int> get pageStream => _pageStreamController.stream;

  // Stream of category changes for listening to category switches
  Stream<String> get categoryStream => _categoryStreamController.stream;

  // Get current page
  int get currentPage => _currentPage;

  // Get current category
  String get currentCategory => _currentCategory;

  // Initialize default tags for all categories
  void _initializeDefaultTags() {
    // Initialize Private tags
    _categoryTags['Private']!.addAll(_defaultPrivatePage1);
    _categoryTags['Private']!.addAll(_defaultPrivatePage2);

    // Initialize Circle tags
    _categoryTags['Circle']!.addAll(_defaultCirclePage1);
    _categoryTags['Circle']!.addAll(_defaultCirclePage2);

    // Initialize Public tags
    _categoryTags['Public']!.addAll(_defaultPublicPage1);
    _categoryTags['Public']!.addAll(_defaultPublicPage2);
  }

  // Switch to a different category's tag set
  void switchCategory(String category) {
    if (_categoryTags.containsKey(category) && category != _currentCategory) {
      _currentCategory = category;
      _currentPage = 0; // Reset to first page when switching categories
      _notifyCategoryListeners();
      _notifyPageListeners();
      _notifyTagListeners();
    }
  }

  // Toggle between pages within current category
  void togglePage() {
    _currentPage = _currentPage == 0 ? 1 : 0;
    _notifyPageListeners();
    _notifyTagListeners();
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

  // Get all tags for current category
  List<TagData> getAllTags() {
    return List.unmodifiable(_categoryTags[_currentCategory] ?? []);
  }

  // Get all tags for a specific category
  List<TagData> getAllTagsForCategory(String category) {
    return List.unmodifiable(_categoryTags[category] ?? []);
  }

  // Get tags for the current page of current category
  List<TagData> getCurrentPageTags() {
    return getTagsForPage(_currentPage);
  }

  // Get tags for a specific page of current category
  List<TagData> getTagsForPage(int page) {
    final categoryTags = _categoryTags[_currentCategory] ?? [];

    if (page == 0) {
      // Page 1: First 7 tags
      return categoryTags.take(7).toList();
    } else {
      // Page 2: Next 7 tags
      return categoryTags.skip(7).take(7).toList();
    }
  }

  // Get a tag by ID from current category
  TagData? getTagById(String id) {
    final categoryTags = _categoryTags[_currentCategory] ?? [];
    try {
      return categoryTags.firstWhere((tag) => tag.id == id);
    } catch (e) {
      return null; // Tag not found
    }
  }

  // Add a new tag to current category
  Future<TagData> addTag(String label) async {
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      throw ArgumentError('Tag label cannot be empty');
    }

    // Generate a unique ID
    int highestId = 0;
    for (var categoryList in _categoryTags.values) {
      for (var tag in categoryList) {
        final id = int.tryParse(tag.id) ?? 0;
        if (id > highestId) highestId = id;
      }
    }
    final newId = (highestId + 1).toString();

    final tag = TagData(id: newId, label: truncatedLabel);

    _categoryTags[_currentCategory]!.add(tag);
    _notifyTagListeners();

    return tag;
  }

  // Update a tag in current category
  Future<TagData?> updateTag(String id, String label) async {
    final categoryTags = _categoryTags[_currentCategory]!;
    final index = categoryTags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return null; // Tag not found
    }

    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      debugPrint('Tag label cannot be empty. Keeping original name.');
      return categoryTags[index];
    }

    if (categoryTags[index].label == truncatedLabel) {
      return categoryTags[index];
    }

    // Check for duplicates within current category
    if (categoryTags.any((t) =>
        t.id != id && t.label.toLowerCase() == truncatedLabel.toLowerCase())) {
      debugPrint('Tag $truncatedLabel already exists. Using original name.');
      return categoryTags[index];
    }

    final updatedTag = categoryTags[index].copyWith(label: truncatedLabel);
    categoryTags[index] = updatedTag;
    _notifyTagListeners();

    return updatedTag;
  }

  // Delete a tag from current category
  Future<bool> deleteTag(String id) async {
    // Don't allow deleting default tags
    if (_isDefaultTag(id)) {
      return false;
    }

    final categoryTags = _categoryTags[_currentCategory]!;
    final index = categoryTags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return false; // Tag not found
    }

    categoryTags.removeAt(index);
    _notifyTagListeners();

    return true;
  }

  // Check if a tag is a default tag
  bool _isDefaultTag(String id) {
    final allDefaults = [
      ..._defaultPrivatePage1,
      ..._defaultPrivatePage2,
      ..._defaultCirclePage1,
      ..._defaultCirclePage2,
      ..._defaultPublicPage1,
      ..._defaultPublicPage2,
    ];
    return allDefaults.any((tag) => tag.id == id);
  }

  // Toggle tag selection in current category
  Future<TagData?> toggleTagSelection(String id) async {
    final categoryTags = _categoryTags[_currentCategory]!;
    final index = categoryTags.indexWhere((tag) => tag.id == id);

    if (index == -1) {
      return null; // Tag not found
    }

    final tag = categoryTags[index];
    final updatedTag = tag.copyWith(isSelected: !tag.isSelected);

    categoryTags[index] = updatedTag;
    _notifyTagListeners();

    return updatedTag;
  }

  // Reset tag selections for current category
  Future<void> resetTagSelections() async {
    final categoryTags = _categoryTags[_currentCategory]!;
    bool changed = false;

    for (int i = 0; i < categoryTags.length; i++) {
      if (categoryTags[i].isSelected) {
        categoryTags[i] = categoryTags[i].copyWith(isSelected: false);
        changed = true;
      }
    }

    if (changed) {
      _notifyTagListeners();
    }
  }

  // Reset to default tags for all categories
  Future<void> resetToDefaults() async {
    // Clear all categories
    for (var key in _categoryTags.keys) {
      _categoryTags[key]!.clear();
    }

    // Reinitialize defaults
    _initializeDefaultTags();

    _currentPage = 0;
    _currentCategory = 'Private';

    _notifyTagListeners();
    _notifyPageListeners();
    _notifyCategoryListeners();
  }

  // Notify tag listeners of changes
  void _notifyTagListeners() {
    if (!_tagsStreamController.isClosed) {
      _tagsStreamController.add(List.unmodifiable(getCurrentPageTags()));
    }
  }

  // Notify page listeners of changes
  void _notifyPageListeners() {
    if (!_pageStreamController.isClosed) {
      _pageStreamController.add(_currentPage);
    }
  }

  // Notify category listeners of changes
  void _notifyCategoryListeners() {
    if (!_categoryStreamController.isClosed) {
      _categoryStreamController.add(_currentCategory);
    }
  }

  // Dispose resources
  void dispose() {
    _tagsStreamController.close();
    _pageStreamController.close();
    _categoryStreamController.close();
  }
}
