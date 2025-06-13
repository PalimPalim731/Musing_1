// services/rectangle_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tag.dart';

/// Service for managing rectangles with 3-character limit and page support
class RectangleService {
  // Singleton pattern
  static final RectangleService _instance = RectangleService._internal();

  factory RectangleService() => _instance;

  RectangleService._internal() {
    // Initialize with default rectangles for both pages
    _rectangles.addAll(_defaultPage1Rectangles);
    _rectangles.addAll(_defaultPage2Rectangles);
  }

  // Maximum rectangle label length constant
  static const int maxRectangleLength = 3;

  // Current active page (0 = first page, 1 = second page)
  int _currentPage = 0;

  // Default rectangles for Page 1 (IDs 101-107)
  final List<TagData> _defaultPage1Rectangles = [
    TagData(id: '101', label: 'A12'),
    TagData(id: '102', label: 'B34'),
    TagData(id: '103', label: 'C56'),
    TagData(id: '104', label: 'D78'),
    TagData(id: '105', label: 'E90'),
    TagData(id: '106', label: 'F11'),
    TagData(id: '107', label: 'G22'),
  ];

  // Default rectangles for Page 2 (IDs 108-114)
  final List<TagData> _defaultPage2Rectangles = [
    TagData(id: '108', label: 'H33'),
    TagData(id: '109', label: 'I44'),
    TagData(id: '110', label: 'J55'),
    TagData(id: '111', label: 'K66'),
    TagData(id: '112', label: 'L77'),
    TagData(id: '113', label: 'M88'),
    TagData(id: '114', label: 'N99'),
  ];

  // In-memory storage for rectangles - in a real app, this would be a database
  final List<TagData> _rectangles = [];

  // Stream controller for broadcasting rectangle changes
  final _rectanglesStreamController =
      StreamController<List<TagData>>.broadcast();

  // Stream controller for broadcasting page changes
  final _pageStreamController = StreamController<int>.broadcast();

  // Stream of rectangles for listening to changes
  Stream<List<TagData>> get rectanglesStream =>
      _rectanglesStreamController.stream;

  // Stream of page changes for listening to page switches
  Stream<int> get pageStream => _pageStreamController.stream;

  // Get current page
  int get currentPage => _currentPage;

  // Toggle between pages
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

  // Get all rectangles
  List<TagData> getAllRectangles() {
    return List.unmodifiable(_rectangles);
  }

  // Get rectangles for the current page
  List<TagData> getCurrentPageRectangles() {
    return getRectanglesForPage(_currentPage);
  }

  // Get rectangles for a specific page
  List<TagData> getRectanglesForPage(int page) {
    if (page == 0) {
      // Page 1: First 7 rectangles
      return _rectangles.take(7).toList();
    } else {
      // Page 2: Next 7 rectangles
      return _rectangles.skip(7).take(7).toList();
    }
  }

  // Get a rectangle by ID
  TagData? getRectangleById(String id) {
    try {
      return _rectangles.firstWhere((rectangle) => rectangle.id == id);
    } catch (e) {
      return null; // Rectangle not found
    }
  }

  // Add a new rectangle
  Future<TagData> addRectangle(String label) async {
    // Truncate label to max length
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      throw ArgumentError('Rectangle label cannot be empty');
    }

    // Generate a unique ID - in a real app, this would be handled by the database
    // For rectangles, use IDs starting from 101
    int highestId = 100;
    for (var rectangle in _rectangles) {
      final id = int.tryParse(rectangle.id) ?? 0;
      if (id > highestId) highestId = id;
    }
    final newId = (highestId + 1).toString();

    final rectangle = TagData(id: newId, label: truncatedLabel);

    _rectangles.add(rectangle);
    _notifyListeners();

    return rectangle;
  }

  // Update a rectangle
  Future<TagData?> updateRectangle(String id, String label) async {
    final index = _rectangles.indexWhere((rectangle) => rectangle.id == id);

    if (index == -1) {
      return null; // Rectangle not found
    }

    // Truncate label to max length
    final truncatedLabel = _truncateLabel(label.trim());

    if (truncatedLabel.isEmpty) {
      debugPrint('Rectangle label cannot be empty. Keeping original name.');
      return _rectangles[index];
    }

    // Don't update if the label is the same
    if (_rectangles[index].label == truncatedLabel) {
      return _rectangles[index];
    }

    // Ensure we're not creating a duplicate
    if (_rectangles.any((r) =>
        r.id != id && r.label.toLowerCase() == truncatedLabel.toLowerCase())) {
      debugPrint(
          'Rectangle $truncatedLabel already exists. Using original name.');
      return _rectangles[index];
    }

    final updatedRectangle = _rectangles[index].copyWith(label: truncatedLabel);
    _rectangles[index] = updatedRectangle;
    _notifyListeners();

    return updatedRectangle;
  }

  // Delete a rectangle
  Future<bool> deleteRectangle(String id) async {
    // Don't allow deleting default rectangles
    if (_isDefaultRectangle(id)) {
      return false;
    }

    final index = _rectangles.indexWhere((rectangle) => rectangle.id == id);

    if (index == -1) {
      return false; // Rectangle not found
    }

    _rectangles.removeAt(index);
    _notifyListeners();

    return true;
  }

  // Check if a rectangle is a default rectangle
  bool _isDefaultRectangle(String id) {
    final allDefaults = [
      ..._defaultPage1Rectangles,
      ..._defaultPage2Rectangles,
    ];
    return allDefaults.any((rectangle) => rectangle.id == id);
  }

  // Toggle rectangle selection
  Future<TagData?> toggleRectangleSelection(String id) async {
    final index = _rectangles.indexWhere((rectangle) => rectangle.id == id);

    if (index == -1) {
      return null; // Rectangle not found
    }

    final rectangle = _rectangles[index];
    final updatedRectangle =
        rectangle.copyWith(isSelected: !rectangle.isSelected);

    _rectangles[index] = updatedRectangle;
    _notifyListeners();

    return updatedRectangle;
  }

  // Reset rectangle selections
  Future<void> resetRectangleSelections() async {
    bool changed = false;

    for (int i = 0; i < _rectangles.length; i++) {
      if (_rectangles[i].isSelected) {
        _rectangles[i] = _rectangles[i].copyWith(isSelected: false);
        changed = true;
      }
    }

    if (changed) {
      _notifyListeners();
    }
  }

  // Reset to default rectangles
  Future<void> resetToDefaults() async {
    _rectangles.clear();
    _rectangles.addAll(_defaultPage1Rectangles);
    _rectangles.addAll(_defaultPage2Rectangles);
    _currentPage = 0;
    _notifyListeners();
    _notifyPageListeners();
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

  // Dispose resources
  void dispose() {
    _rectanglesStreamController.close();
    _pageStreamController.close();
  }
}
