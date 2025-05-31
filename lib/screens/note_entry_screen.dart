// screens/note_entry_screen.dart

import 'package:flutter/material.dart';
import '../config/constants/layout.dart';
import '../widgets/category/category_sidebar.dart';
import '../widgets/note/note_content.dart';
import '../widgets/tag/tag_sidebar.dart';
import '../widgets/bottom_bar/bottom_action_bar.dart';
import '../widgets/theme/theme_toggle_button.dart';
import '../widgets/tag/tag_page_toggle_button.dart';
import '../services/note_service.dart';
import '../services/tag_service.dart';
import '../services/rectangle_service.dart'; // ← ADD THIS LINE
import '../services/theme_service.dart';
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
  // Size selection removed - will use default 'Medium' for all notes

  // Applied tags to the current note (tags that have been dragged onto the note)
  final List<TagData> _appliedTags = [];

  // Services for data operations
  final NoteService _noteService = NoteService();
  final TagService _tagService = TagService();
  final ThemeService _themeService = ThemeService();

  // Controller for the note text input
  final TextEditingController _noteController = TextEditingController();

  // Focus node to manage keyboard focus
  final FocusNode _noteFocusNode = FocusNode();

  // Track current tag page
  late int _currentTagPage;

  @override
  void initState() {
    super.initState();

    // Initialize current tag page
    _currentTagPage = _tagService.currentPage;

    // Listen to tag changes (like renames) to update applied tags
    _tagService.tagsStream.listen((updatedTags) {
      // If any applied tags have been renamed, update them
      if (_appliedTags.isNotEmpty) {
        setState(() {
          // Update our applied tags with the latest tag data
          // Note: updatedTags now only contains current page tags, so we need to check all tags
          final allTags = _tagService.getAllTags();

          for (int i = 0; i < _appliedTags.length; i++) {
            final currentTag = _appliedTags[i];
            final updatedTag = allTags.firstWhere(
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

    // Listen to tag page changes
    _tagService.pageStream.listen((newPage) {
      setState(() {
        _currentTagPage = newPage;
      });
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
    final bool isCompact =
        MediaQuery.of(context).size.width < AppLayout.tabletBreakpoint;
    final double spacing = AppLayout.getSpacing(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            LayoutBuilder(
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

                          // Main note content area with callbacks for actions (size selection removed)
                          Expanded(
                            flex: 8,
                            child: NoteContent(
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

            // Theme toggle button in top left corner
            ThemeToggleButton(
              onToggle: _themeService.toggleTheme,
              currentThemeMode: _themeService.currentThemeMode,
              isCompact: isCompact,
            ),

            // Tag page toggle button in top right corner
            TagPageToggleButton(
              onToggle: _handleTagPageToggle,
              currentPage: _currentTagPage,
              isCompact: isCompact,
            ),
          ],
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

  // Handle tag page toggle
  void _handleTagPageToggle() {
    _tagService.togglePage();
    debugPrint('Switched to tag page ${_tagService.currentPage + 1}');
  }

  // Handle tag dropped onto the note
  void _handleTagAdded(TagData tag) {
    setState(() {
      if (!_appliedTags.contains(tag)) {
        _appliedTags.add(tag);
      }
    });
    debugPrint('Tag added to note: ${tag.label}');
  }

  // Handle removal of tag from the note
  void _handleTagRemoved(TagData tag) {
    setState(() {
      _appliedTags.removeWhere((t) => t.id == tag.id);
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

  // Save the current note (now uses default 'Medium' size)
  void _saveCurrentNote() {
    final content = _noteController.text;
    if (content.isEmpty) return;

    // Extract tag IDs from applied tags
    final tagIds = _appliedTags.map((tag) => tag.id).toList();

    // Call the note service to save the note with default 'Medium' size
    _noteService
        .addNote(
      content: content,
      category: _selectedCategory,
      size: 'Medium', // Default size since selector was removed
      tagIds: tagIds,
    )
        .then((note) {
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

              // Reset applied tags
              setState(() {
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
