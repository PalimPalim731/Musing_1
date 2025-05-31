// services/rectangle_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tag.dart';

/// Service for managing rectangles with 3-character limit
class RectangleService {
  // Singleton pattern
  static final RectangleService _instance = RectangleService._internal();

  factory RectangleService() => _instance;

  RectangleService._internal() {
    // Initialize with default rectangles
    _rectangles.addAll(_defaultRectangles);
  }

  // Maximum rectangle label length constant
  static const int maxRectangleLength = 3;

  // Default rectangles (IDs 101-107 to avoid conflicts with tags)
  final List<TagData> _defaultRectangles = [
    TagData(id: '101', label: 'A12'),
    TagData(id: '102', label: 'B34'),
    TagData(id: '103', label: 'C56'),
    TagData(id: '104', label: 'D78'),
    TagData(id: '105', label: 'E90'),
    TagData(id: '106', label: 'F11'),
    TagData(id: '107', label: 'G22'),
  ];

  // In-memory storage for rectangles - in a real app, this would be a database
  final List<TagData> _rectangles = [];

  // Stream controller for broadcasting rectangle changes
  final _rectanglesStreamController =
      StreamController<List<TagData>>.broadcast();

  // Stream of rectangles for listening to changes
  Stream<List<TagData>> get rectanglesStream =>
      _rectanglesStreamController.stream;

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
    if (_defaultRectangles.any((rectangle) => rectangle.id == id)) {
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
    _rectangles.addAll(_defaultRectangles);
    _notifyListeners();
  }

  // Notify listeners of changes
  void _notifyListeners() {
    if (!_rectanglesStreamController.isClosed) {
      _rectanglesStreamController.add(List.unmodifiable(_rectangles));
    }
  }

  // Dispose resources
  void dispose() {
    _rectanglesStreamController.close();
  }
}
