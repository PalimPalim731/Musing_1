// services/category_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for managing categories
class CategoryService {
  // Singleton pattern
  static final CategoryService _instance = CategoryService._internal();
  
  factory CategoryService() => _instance;
  
  CategoryService._internal() {
    // Initialize with default categories
    _categories.addAll(_defaultCategories);
  }
  
  // Default categories
  final List<String> _defaultCategories = ['Private', 'Public'];
  
  // In-memory storage for categories - in a real app, this would be a database
  final List<String> _categories = [];
  
  // Stream controller for broadcasting category changes
  final _categoriesStreamController = StreamController<List<String>>.broadcast();
  
  // Stream of categories for listening to changes
  Stream<List<String>> get categoriesStream => _categoriesStreamController.stream;
  
  // Get all categories
  List<String> getAllCategories() {
    return List.unmodifiable(_categories);
  }
  
  // Check if a category exists
  bool categoryExists(String category) {
    return _categories.contains(category);
  }
  
  // Add a new category
  Future<bool> addCategory(String category) async {
    if (categoryExists(category)) {
      return false; // Category already exists
    }
    
    _categories.add(category);
    _notifyListeners();
    
    return true;
  }
  
  // Remove a category
  Future<bool> removeCategory(String category) async {
    // Don't allow removing default categories
    if (_defaultCategories.contains(category)) {
      return false;
    }
    
    final removed = _categories.remove(category);
    
    if (removed) {
      _notifyListeners();
    }
    
    return removed;
  }
  
  // Rename a category
  Future<bool> renameCategory(String oldName, String newName) async {
    // Don't allow renaming default categories
    if (_defaultCategories.contains(oldName)) {
      return false;
    }
    
    // Check if the new name already exists
    if (categoryExists(newName)) {
      return false;
    }
    
    final index = _categories.indexOf(oldName);
    
    if (index == -1) {
      return false; // Category not found
    }
    
    _categories[index] = newName;
    _notifyListeners();
    
    return true;
  }
  
  // Reset to default categories
  Future<void> resetToDefaults() async {
    _categories.clear();
    _categories.addAll(_defaultCategories);
    _notifyListeners();
  }
  
  // Notify listeners of changes
  void _notifyListeners() {
    if (!_categoriesStreamController.isClosed) {
      _categoriesStreamController.add(List.unmodifiable(_categories));
    }
  }
  
  // Dispose resources
  void dispose() {
    _categoriesStreamController.close();
  }
}