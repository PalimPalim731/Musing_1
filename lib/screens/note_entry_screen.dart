// screens/note_entry_screen.dart

import 'package:flutter/material.dart';
import '../config/constants/layout.dart';
import '../widgets/category/category_sidebar.dart';
import '../widgets/note/note_content.dart';
import '../widgets/tag/tag_sidebar.dart';
import '../widgets/bottom_bar/bottom_action_bar.dart';
import '../services/note_service.dart';
import '../services/tag_service.dart';
import '../models/note.dart';
import '../models/tag.dart';

/// Main screen for note entry and management
class NoteEntryScreen extends StatefulWidget {
  const NoteEntryScreen({super.key});

  @override
  State<NoteEntryScreen> createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  // Active selections with default values
  String _selectedCategory = 'Private';
  String _selectedSize = 'Medium';
  
  // Selected tag IDs
  final List<String> _selectedTagIds = [];
  
  // Applied tags to the current note
  final List<TagData> _appliedTags = [];
  
  // Services for data operations
  final NoteService _noteService = NoteService();
  final TagService _tagService = TagService();
  
  // Controller for the note text input
  final TextEditingController _noteController = TextEditingController();
  
  // Focus node to manage keyboard focus
  final FocusNode _noteFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    // Listen to tag changes (like renames) to update applied tags
    _tagService.tagsStream.listen((updatedTags) {
      // If any applied tags have been renamed, update them
      if (_appliedTags.isNotEmpty) {
        setState(() {
          // Update our applied tags with the latest tag data
          for (int i = 0; i < _appliedTags.length; i++) {
            final currentTag = _appliedTags[i];
            final updatedTag = updatedTags.firstWhere(
              (tag) => tag.id == currentTag.id,
              orElse: () => currentTag, // Keep the old one if not found
            );
            
            // Replace tag if it was updated
            if (updatedTag.label != currentTag.label) {
              _appliedTags[i] = updatedTag;
            }
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    // Clean up controllers and focus nodes when the widget is disposed
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get responsive values
    final bool isCompact = MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    final double spacing = AppLayout.getSpacing(context);
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Main content area
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left spacing
                      SizedBox(width: spacing),

                      // Left sidebar with category buttons
                      CategorySidebar(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _selectCategory,
                        screenHeight: constraints.maxHeight,
                        isCompact: isCompact,
                      ),

                      // Spacing between sidebar and main content
                      SizedBox(width: spacing),

                      // Main note content area with callbacks for actions
                      Expanded(
                        flex: 8,
                        child: NoteContent(
                          selectedSize: _selectedSize,
                          onSizeSelected: _selectSize,
                          noteController: _noteController,
                          focusNode: _noteFocusNode,
                          appliedTags: _appliedTags,
                          onTagAdded: _handleTagAdded,
                          onTagRemoved: _handleTagRemoved,
                          onDelete: _handleDeleteNote,
                          onUndo: _handleUndoNote,
                          onFormat: _handleFormatNote,
                          onCamera: _handleCameraPressed,
                          onMic: _handleMicPressed,
                          onLink: _handleLinkPressed,
                        ),
                      ),

                      // Spacing between main content and tag sidebar
                      SizedBox(width: spacing),

                      // Right sidebar with tags
                      TagSidebar(
                        screenHeight: constraints.maxHeight,
                        isCompact: isCompact,
                        onTagSelected: _handleTagSelected,
                      ),

                      // Right spacing
                      SizedBox(width: spacing),
                    ],
                  ),
                ),

                // Bottom action bar
                BottomActionBar(
                  onSettingsPressed: _handleSettingsPressed,
                  onExplorePressed: _handleExplorePressed,
                  onProfilePressed: _handleProfilePressed,
                  isCompact: isCompact,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // State management methods
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _selectSize(String size) {
    setState(() {
      _selectedSize = size;
    });
  }
  
  // Handle tag selection in the sidebar
  void _handleTagSelected(String tagId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedTagIds.contains(tagId)) {
          _selectedTagIds.add(tagId);
        }
      } else {
        _selectedTagIds.remove(tagId);
      }
    });
    debugPrint('Selected tags: $_selectedTagIds');
  }
  
  // Handle tag dropped onto the note
  void _handleTagAdded(TagData tag) {
    setState(() {
      if (!_appliedTags.contains(tag)) {
        _appliedTags.add(tag);
        // Also add to selected tags if not already there
        if (!_selectedTagIds.contains(tag.id)) {
          _selectedTagIds.add(tag.id);
        }
      }
    });
    debugPrint('Tag added to note: ${tag.label}');
  }
  
  // Find a TagData from the TagService by id
  TagData? _findTagById(String id) {
    return _tagService.getTagById(id);
  }
  
  // Handle removal of tag from the note
  void _handleTagRemoved(TagData tag) {
    setState(() {
      _appliedTags.removeWhere((t) => t.id == tag.id);
      // Note: We're not removing from _selectedTagIds here,
      // as that's more for categorization
    });
    debugPrint('Tag removed from note: ${tag.label}');
  }

  // Handler methods for bottom bar actions
  void _handleSettingsPressed() {
    // TODO: Implement settings navigation
    debugPrint('Settings pressed');
  }

  void _handleExplorePressed() {
    // In a real app, save the note first if needed
    // This is now a separate action since we removed the Save button
    _saveCurrentNote();
    
    // TODO: Navigate to explore screen
    debugPrint('Explore pressed');
  }

  void _handleProfilePressed() {
    // TODO: Implement profile navigation
    debugPrint('Profile pressed');
  }
  
  // Save the current note
  void _saveCurrentNote() {
    final content = _noteController.text;
    if (content.isEmpty) return;
    
    // Call the note service to save the note
    _noteService.addNote(
      content: content,
      category: _selectedCategory,
      size: _selectedSize,
      tagIds: List<String>.from(_selectedTagIds),
    ).then((note) {
      debugPrint('Note saved: ${note.id}');
      
      // Show confirmation to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Clear the note input and reset state
      _noteController.clear();
      
      setState(() {
        _selectedTagIds.clear();
        _appliedTags.clear();
      });
    });
  }
  
  // Centralized note action handlers
  void _handleDeleteNote() {
    if (_noteController.text.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _noteController.clear();
              Navigator.of(context).pop();
              
              // Reset selected tags and applied tags
              setState(() {
                _selectedTagIds.clear();
                _appliedTags.clear();
              });
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
  
  void _handleUndoNote() {
    // In a real implementation, you would track changes
    // and implement an undo stack
    
    // For now just log the action
    debugPrint('Undo pressed');
  }
  
  void _handleFormatNote() {
    // This is a placeholder for future formatting functionality
    debugPrint('Format pressed - Feature to be implemented later');
    
    // Sample implementation - show a snackbar to indicate the feature is coming
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text formatting options coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _handleCameraPressed() {
    // In a real implementation, you would:
    // - Request camera permissions if needed
    // - Launch camera interface
    // - Handle the captured image
    
    debugPrint('Camera pressed');
  }
  
  void _handleMicPressed() {
    // In a real implementation, you would:
    // - Request microphone permissions if needed
    // - Start voice recording
    // - Handle the recorded audio
    
    debugPrint('Mic pressed');
  }
  
  void _handleLinkPressed() {
    // In a real implementation, you would:
    // - Show a dialog to enter a URL
    // - Validate and attach the link
    
    debugPrint('Link pressed');
  }
}