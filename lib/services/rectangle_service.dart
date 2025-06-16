// services/rectangle_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tag.dart';

/// Service for managing rectangles with 3-character limit, page support, and category-specific sets
class RectangleService {
  // Singleton pattern
  static final RectangleService _instance = RectangleService._internal();

  factory RectangleService() => _instance;

  RectangleService._internal() {
    // Initialize with default rectangles for all categories
    _initializeDefaultRectangles();
    // Start with Private category
    _currentCategory = 'Private';
  }

  // Maximum rectangle label length constant
  static const int maxRectangleLength = 3;

  // Current active page (0 = first page, 1 = second page)
  int _currentPage = 0;

  // Current active category
  String _currentCategory = 'Private';

  // Default rectangles for Private category - Page 1 (IDs 101-107)
  final List<TagData> _defaultPrivatePage1 = [
    TagData(id: '101', label: 'A12'),
    TagData(id: '102', label: 'B34'),
    TagData(id: '103', label: 'C56'),
    TagData(id: '104', label: 'D78'),
    TagData(id: '105', label: 'E90'),
    TagData(id: '106', label: 'F11'),
    TagData(id: '107', label: 'G22'),
  ];

  // Default rectangles for Private category - Page 2 (IDs 108-114)
  final List<TagData> _defaultPrivatePage2 = [
    TagData(id: '108', label: 'H33'),
    TagData(id: '109', label: 'I44'),
    TagData(id: '110', label: 'J55'),
    TagData(id: '111', label: 'K66'),
    TagData(id: '112', label: 'L77'),
    TagData(id: '113', label: 'M88'),
    TagData(id: '114', label: 'N99'),
  ];

  // Default rectangles for Circle category - Page 1 (IDs 115-121)
  final List<TagData> _defaultCirclePage1 = [
    TagData(id: '115', label: 'P01'),
    TagData(id: '116', label: 'Q02'),
    TagData(id: '117', label: 'R03'),
    TagData(id: '118', label: 'S04'),
    TagData(id: '119', label: 'T05'),
    TagData(id: '120', label: 'U06'),
    TagData(id: '121', label: 'V07'),
  ];

  // Default rectangles for Circle category - Page 2 (IDs 122-128)
  final List<TagData> _defaultCirclePage2 = [
    TagData(id: '122', label: 'W08'),
    TagData(id: '123', label: 'X09'),
    TagData(id: '124', label: 'Y10'),
    TagData(id: '125', label: 'Z11'),
    TagData(id: '126', label: 'A21'),
    TagData(id: '127', label: 'B22'),
    TagData(id: '128', label: 'C23'),
  ];

  // Default rectangles for Public category - Page 1 (IDs 129-135)
  final List<TagData> _defaultPublicPage1 = [
    TagData(id: '129', label: 'D24'),
    TagData(id: '130', label: 'E25'),
    TagData(id: '131', label: 'F26'),
    TagData(id: '132', label: 'G27'),
    TagData(id: '133', label: 'H28'),
    TagData(id: '134', label: 'I29'),
    TagData(id: '135', label: 'J30'),
  ];

  // Default rectangles for Public category - Page 2 (IDs 136-142)
  final List<TagData> _defaultPublicPage2 = [
    TagData(id: '136', label: 'K31'),
    TagData(id: '137', label: 'L32'),
    TagData(id: '138', label: 'M33'),
    TagData(id: '139', label: 'N34'),
    TagData(id: '140', label: 'O35'),
    TagData(id: '141', label: 'P36'),
    TagData(id: '142', label: 'Q37'),
  ];

  // Storage for all rectangles organized by category
  final Map<String, List<TagData>> _categoryRectangles = {
    'Private': [],
    'Circle': [],
    'Public': [],
  };

  // Stream controller for broadcasting rectangle changes
  final _rectanglesStreamController =
      StreamController<List<TagData>>.broadcast();

  // Stream controller for broadcasting page changes
  final _pageStreamController = StreamController<int>.broadcast();

  // Stream controller for broadcasting category changes
  final _categoryStreamController = StreamController<String>.broadcast();

  // Stream of rectangles for listening to changes
  Stream<List<TagData>> get rectanglesStream =>
      _rectanglesStreamController.stream;

  // Stream of page changes for listening to page switches
  Stream<int> get pageStream => _pageStreamController.stream;

  // Stream of category changes for listening to category switches
  Stream<String> get categoryStream => _categoryStreamController.stream;

  // Get current page
  int get currentPage => _currentPage;

  // Get current category
  String get currentCategory => _currentCategory;

  // Initialize default rectangles for all categories
  void _initializeDefaultRectangles() {
    // Initialize Private rectangles
    _categoryRectangles['Private']!.addAll(_defaultPrivatePage1);
    _categoryRectangles['Private']!.addAll(_defaultPrivatePage2);

    // Initialize Circle rectangles
    _categoryRectangles['Circle']!.addAll(_defaultCirclePage1);
    _categoryRectangles['Circle']!.addAll(_defaultCirclePage2);

    // Initialize Public rectangles
    _categoryRectangles['Public']!.addAll(_defaultPublicPage1);
    _categoryRectangles['Public']!.addAll(_defaultPublicPage2);
  }

  // Switch to a different category's rectangle set
  void switchCategory(String category) {
    if (_categoryRectangles.containsKey(category) &&
        category != _currentCategory) {
      _currentCategory = category;
      _currentPage = 0; // Reset to first page when switching categories
      _notifyCategoryListeners();
      _notifyPageListeners();
      _notifyListeners();
    }
  }

  // Toggle between pages within current category
  void togglePage() {
    _currentPage = _currentPage == 0 ? 1 : 0;
    _notifyPageListeners();
    _notifyListeners();
  }

  // Set specific page
  void setPage(int page) {
    if (page >= 0 && page <= 1 && page != _currentPage) {
      _currentPage = page;
      _notifyPageListeners();
      _notifyListeners();
    }
  }

  // Utility method to truncate rectangle labels to max length
  String _truncateLabel(String label) {
    return label.length > maxRectangleLength
        ? label.substring(0, maxRectangleLength)
        : label;
  }

  // Get all rectangles for current category
  List<TagData> getAllRectangles() {
    return List.unmodifiable(_categoryRectangles[_currentCategory] ?? []);
  }

  // Get all rectangles for a specific category
  List<TagData> getAllRectanglesForCategory(String category) {
    return List.unmodifiable(_categoryRectangles[category] ?? []);
  }

  // Get rectangles for the current page of current category
  List<TagData> getCurrentPageRectangles() {
    return getRectanglesForPage(_currentPage);
  }

  // Get rectangles for a specific page of current category
  List<TagData> getRectanglesForPage(int page) {
    final categoryRectangles = _categoryRectangles[_currentCategory] ?? [];

    if (page == 0) {
      // Page 1: First 7 rectangles
      return categoryRectangles.take(7).toList();
    } else {
      // Page 2: Next 7 rectangles
      return categoryRectangles.skip(7).take(7).toList();
    }
  }

  // Get a rectangle by ID from current category
  TagData? getRectangleById(String id) {
    final categoryRectangles = _categoryRectangles[_currentCategory] ?? [];
    try {
      return categoryRectangles.firstWhere((rectangle) => rectangle.id == id);
    } catch (e) {
      return null; // Rectangle not found
    }
  }

  // Add a new rectangle to current category
  Future<TagData> addRectangle(String label) async {
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      throw ArgumentError('Rectangle label cannot be empty');
    }

    // Generate a unique ID
    int highestId = 100;
    for (var categoryList in _categoryRectangles.values) {
      for (var rectangle in categoryList) {
        final id = int.tryParse(rectangle.id) ?? 0;
        if (id > highestId) highestId = id;
      }
    }
    final newId = (highestId + 1).toString();

    final rectangle = TagData(id: newId, label: truncatedLabel);

    _categoryRectangles[_currentCategory]!.add(rectangle);
    _notifyListeners();

    return rectangle;
  }

  // Update a rectangle in current category
  Future<TagData?> updateRectangle(String id, String label) async {
    final categoryRectangles = _categoryRectangles[_currentCategory]!;
    final index =
        categoryRectangles.indexWhere((rectangle) => rectangle.id == id);

    if (index == -1) {
      return null; // Rectangle not found
    }

    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      debugPrint('Rectangle label cannot be empty. Keeping original name.');
      return categoryRectangles[index];
    }

    if (categoryRectangles[index].label == truncatedLabel) {
      return categoryRectangles[index];
    }

    // Check for duplicates within current category
    if (categoryRectangles.any((r) =>
        r.id != id && r.label.toLowerCase() == truncatedLabel.toLowerCase())) {
      debugPrint(
          'Rectangle $truncatedLabel already exists. Using original name.');
      return categoryRectangles[index];
    }

    final updatedRectangle =
        categoryRectangles[index].copyWith(label: truncatedLabel);
    categoryRectangles[index] = updatedRectangle;
    _notifyListeners();

    return updatedRectangle;
  }

  // Delete a rectangle from current category
  Future<bool> deleteRectangle(String id) async {
    // Don't allow deleting default rectangles
    if (_isDefaultRectangle(id)) {
      return false;
    }

    final categoryRectangles = _categoryRectangles[_currentCategory]!;
    final index =
        categoryRectangles.indexWhere((rectangle) => rectangle.id == id);

    if (index == -1) {
      return false; // Rectangle not found
    }

    categoryRectangles.removeAt(index);
    _notifyListeners();

    return true;
  }

  // Check if a rectangle is a default rectangle
  bool _isDefaultRectangle(String id) {
    final allDefaults = [
      ..._defaultPrivatePage1,
      ..._defaultPrivatePage2,
      ..._defaultCirclePage1,
      ..._defaultCirclePage2,
      ..._defaultPublicPage1,
      ..._defaultPublicPage2,
    ];
    return allDefaults.any((rectangle) => rectangle.id == id);
  }

  // Toggle rectangle selection in current category
  Future<TagData?> toggleRectangleSelection(String id) async {
    final categoryRectangles = _categoryRectangles[_currentCategory]!;
    final index =
        categoryRectangles.indexWhere((rectangle) => rectangle.id == id);

    if (index == -1) {
      return null; // Rectangle not found
    }

    final rectangle = categoryRectangles[index];
    final updatedRectangle =
        rectangle.copyWith(isSelected: !rectangle.isSelected);

    categoryRectangles[index] = updatedRectangle;
    _notifyListeners();

    return updatedRectangle;
  }

  // Reset rectangle selections for current category
  Future<void> resetRectangleSelections() async {
    final categoryRectangles = _categoryRectangles[_currentCategory]!;
    bool changed = false;

    for (int i = 0; i < categoryRectangles.length; i++) {
      if (categoryRectangles[i].isSelected) {
        categoryRectangles[i] =
            categoryRectangles[i].copyWith(isSelected: false);
        changed = true;
      }
    }

    if (changed) {
      _notifyListeners();
    }
  }

  // Reset to default rectangles for all categories
  Future<void> resetToDefaults() async {
    // Clear all categories
    for (var key in _categoryRectangles.keys) {
      _categoryRectangles[key]!.clear();
    }

    // Reinitialize defaults
    _initializeDefaultRectangles();

    _currentPage = 0;
    _currentCategory = 'Private';

    _notifyListeners();
    _notifyPageListeners();
    _notifyCategoryListeners();
  }

  // Notify listeners of changes
  void _notifyListeners() {
    if (!_rectanglesStreamController.isClosed) {
      _rectanglesStreamController
          .add(List.unmodifiable(getCurrentPageRectangles()));
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
    _rectanglesStreamController.close();
    _pageStreamController.close();
    _categoryStreamController.close();
  }
}
