// services/note_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/note.dart';

/// Service for managing notes
class NoteService {
  // Singleton pattern
  static final NoteService _instance = NoteService._internal();
  
  factory NoteService() => _instance;
  
  NoteService._internal();
  
  // In-memory storage for notes - in a real app, this would be a database
  final List<Note> _notes = [];
  
  // Stream controller for broadcasting note changes
  final _notesStreamController = StreamController<List<Note>>.broadcast();
  
  // Stream of notes for listening to changes
  Stream<List<Note>> get notesStream => _notesStreamController.stream;
  
  // Get all notes
  List<Note> getAllNotes() {
    return List.unmodifiable(_notes);
  }
  
  // Get notes by category
  List<Note> getNotesByCategory(String category) {
    return _notes.where((note) => note.category == category).toList();
  }
  
  // Get notes by tag
  List<Note> getNotesByTag(String tagId) {
    return _notes.where((note) => note.tagIds.contains(tagId)).toList();
  }
  
  // Get a note by ID
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null; // Note not found
    }
  }
  
  // Add a new note
  Future<Note> addNote({
    required String content,
    required String category,
    required String size,
    List<String> tagIds = const [],
  }) async {
    // Generate a unique ID - in a real app, this would be handled by the database
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final note = Note.create(
      id: id,
      content: content,
      category: category,
      size: size,
      tagIds: tagIds,
    );
    
    _notes.add(note);
    _notifyListeners();
    
    return note;
  }
  
  // Update an existing note
  Future<Note?> updateNote({
    required String id,
    String? content,
    String? category,
    String? size,
    List<String>? tagIds,
  }) async {
    final index = _notes.indexWhere((note) => note.id == id);
    
    if (index == -1) {
      return null; // Note not found
    }
    
    final updatedNote = _notes[index].update(
      content: content,
      category: category,
      size: size,
      tagIds: tagIds,
    );
    
    _notes[index] = updatedNote;
    _notifyListeners();
    
    return updatedNote;
  }
  
  // Delete a note
  Future<bool> deleteNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    
    if (index == -1) {
      return false; // Note not found
    }
    
    _notes.removeAt(index);
    _notifyListeners();
    
    return true;
  }
  
  // Add or remove a tag from a note
  Future<Note?> toggleNoteTag(String noteId, String tagId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    
    if (index == -1) {
      return null; // Note not found
    }
    
    final note = _notes[index];
    List<String> newTagIds;
    
    if (note.tagIds.contains(tagId)) {
      // Remove the tag
      newTagIds = List.from(note.tagIds)..remove(tagId);
    } else {
      // Add the tag
      newTagIds = List.from(note.tagIds)..add(tagId);
    }
    
    final updatedNote = note.update(tagIds: newTagIds);
    _notes[index] = updatedNote;
    _notifyListeners();
    
    return updatedNote;
  }
  
  // Notify listeners of changes
  void _notifyListeners() {
    if (!_notesStreamController.isClosed) {
      _notesStreamController.add(List.unmodifiable(_notes));
    }
  }
  
  // Dispose resources
  void dispose() {
    _notesStreamController.close();
  }
}