// screens/note_entry_screen.dart

import 'package:flutter/material.dart';
import '../config/constants/layout.dart';
import '../widgets/category/category_sidebar.dart';
import '../widgets/category/category_separator_line.dart';
import '../widgets/note/note_content.dart';
import '../widgets/tag/tag_sidebar.dart';
import '../widgets/bottom_bar/bottom_action_bar.dart';
import '../widgets/tag/tag_page_toggle_button.dart';
import '../widgets/quick_tag/quick_tag_page_toggle_button.dart';
import '../services/note_service.dart';
import '../services/tag_service.dart';
import '../services/rectangle_service.dart';
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

  // Applied tags to the current note (separated by type)
  final List<TagData> _appliedQuickTags = []; // Rectangle-based tags (3 chars)
  final List<TagData> _appliedRegularTags = []; // Sidebar tags (longer names)

  // Services for data operations
  final NoteService _noteService = NoteService();
  final TagService _tagService = TagService();
  final RectangleService _rectangleService = RectangleService();

  // Controller for the note text input
  final TextEditingController _noteController = TextEditingController();

  // Focus node to manage keyboard focus
  final FocusNode _noteFocusNode = FocusNode();

  // Track current tag page
  late int _currentTagPage;

  // Track current quick-tag page
  late int _currentQuickTagPage;

  @override
  void initState() {
    super.initState();

    // Initialize current tag page
    _currentTagPage = _tagService.currentPage;

    // Initialize current quick-tag page
    _currentQuickTagPage = _rectangleService.currentPage;

    // Listen to tag changes (like renames) to update applied tags
    _tagService.tagsStream.listen((updatedTags) {
      // Update applied regular tags if any have been renamed
      if (_appliedRegularTags.isNotEmpty) {
        setState(() {
          final allTags = _tagService.getAllTags();

          for (int i = 0; i < _appliedRegularTags.length; i++) {
            final currentTag = _appliedRegularTags[i];
            final updatedTag = allTags.firstWhere(
              (tag) => tag.id == currentTag.id,
              orElse: () => currentTag,
            );

            if (updatedTag.label != currentTag.label) {
              _appliedRegularTags[i] = updatedTag;
            }
          }
        });
      }
    });

    // Listen to rectangle changes (like renames) to update applied quick-tags
    _rectangleService.rectanglesStream.listen((updatedRectangles) {
      if (_appliedQuickTags.isNotEmpty) {
        setState(() {
          // Need to get all rectangles from current category, not just current page
          final allRectangles = _rectangleService.getAllRectangles();

          for (int i = 0; i < _appliedQuickTags.length; i++) {
            final currentTag = _appliedQuickTags[i];
            final updatedRectangle = allRectangles.firstWhere(
              (rectangle) => rectangle.id == currentTag.id,
              orElse: () => currentTag,
            );

            if (updatedRectangle.label != currentTag.label) {
              _appliedQuickTags[i] = updatedRectangle;
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

    // Listen to tag category changes to update UI
    _tagService.categoryStream.listen((newActiveCategory) {
      // Update UI if needed when tag category changes
      setState(() {});
    });

    // Listen to rectangle page changes
    _rectangleService.pageStream.listen((newPage) {
      setState(() {
        _currentQuickTagPage = newPage;
      });
    });

    // Listen to rectangle category changes to update UI
    _rectangleService.categoryStream.listen((newActiveCategory) {
      // Update UI if needed when rectangle category changes
      setState(() {});
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

                          // Visual separator line between category sidebar and note content
                          CategorySeparatorLine(
                            spacing: spacing,
                            maxHeight: constraints.maxHeight,
                            isCompact: isCompact,
                          ),

                          // Main note content area with callbacks for actions
                          Expanded(
                            flex: 8,
                            child: NoteContent(
                              noteController: _noteController,
                              focusNode: _noteFocusNode,
                              appliedQuickTags: _appliedQuickTags,
                              appliedRegularTags: _appliedRegularTags,
                              selectedCategory: _selectedCategory,
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

            // Toggle buttons
            // Quick-tag page toggle button in top left corner
            QuickTagPageToggleButton(
              onToggle: _handleQuickTagPageToggle,
              currentPage: _currentQuickTagPage,
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

    // Switch both tag service and rectangle service to this category's sets
    _tagService.switchCategory(category);
    _rectangleService.switchCategory(category);
    debugPrint('Switched to $category category for both tags and quick-tags');
  }

  // Handle tag page toggle
  void _handleTagPageToggle() {
    _tagService.togglePage();
    debugPrint('Switched to tag page ${_tagService.currentPage + 1}');
  }

  // Handle quick-tag page toggle
  void _handleQuickTagPageToggle() {
    _rectangleService.togglePage();
    debugPrint(
        'Switched to quick-tag page ${_rectangleService.currentPage + 1}');
  }

  // Determine if a tag is a quick-tag (rectangle) based on ID
  bool _isQuickTag(TagData tag) {
    final id = int.tryParse(tag.id) ?? 0;
    return id >= 101; // Rectangle IDs start from 101
  }

  // Handle tag dropped onto the note
  void _handleTagAdded(TagData tag) {
    setState(() {
      if (_isQuickTag(tag)) {
        // Add to quick-tags if not already present
        if (!_appliedQuickTags.any((t) => t.id == tag.id)) {
          _appliedQuickTags.add(tag);
          debugPrint('Quick-tag added to note: ${tag.label}');
        }
      } else {
        // Add to regular-tags if not already present
        if (!_appliedRegularTags.any((t) => t.id == tag.id)) {
          _appliedRegularTags.add(tag);
          debugPrint('Regular-tag added to note: ${tag.label}');
        }
      }
    });
  }

  // Handle removal of tag from the note
  void _handleTagRemoved(TagData tag) {
    setState(() {
      if (_isQuickTag(tag)) {
        _appliedQuickTags.removeWhere((t) => t.id == tag.id);
        debugPrint('Quick-tag removed from note: ${tag.label}');
      } else {
        _appliedRegularTags.removeWhere((t) => t.id == tag.id);
        debugPrint('Regular-tag removed from note: ${tag.label}');
      }
    });
  }

  // Handler methods for bottom bar actions
  void _handleSettingsPressed() {
    // TODO: Implement settings navigation
    debugPrint('Settings pressed');
  }

  void _handleExplorePressed() {
    // Save the note first if needed
    _saveCurrentNote();

    // TODO: Navigate to explore screen
    debugPrint('Explore pressed');
  }

  void _handleProfilePressed() {
    // TODO: Implement profile navigation
    debugPrint('Profile pressed');
  }

  // Save the current note (combines both tag types)
  void _saveCurrentNote() {
    final content = _noteController.text;
    if (content.isEmpty) return;

    // Combine all applied tag IDs (both quick-tags and regular-tags)
    final allTagIds = [
      ..._appliedQuickTags.map((tag) => tag.id),
      ..._appliedRegularTags.map((tag) => tag.id),
    ];

    // Call the note service to save the note
    _noteService
        .addNote(
      content: content,
      category: _selectedCategory,
      size: 'Medium', // Default size
      tagIds: allTagIds,
    )
        .then((note) {
      debugPrint('Note saved: ${note.id}');
      debugPrint(
          'Quick-tags: ${_appliedQuickTags.map((t) => t.label).join(", ")}');
      debugPrint(
          'Regular-tags: ${_appliedRegularTags.map((t) => t.label).join(", ")}');

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
        _appliedQuickTags.clear();
        _appliedRegularTags.clear();
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

              // Reset both types of applied tags
              setState(() {
                _appliedQuickTags.clear();
                _appliedRegularTags.clear();
              });
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _handleUndoNote() {
    debugPrint('Undo pressed');
  }

  void _handleFormatNote() {
    debugPrint('Format pressed - Feature to be implemented later');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text formatting options coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCameraPressed() {
    debugPrint('Camera pressed');
  }

  void _handleMicPressed() {
    debugPrint('Mic pressed');
  }

  void _handleLinkPressed() {
    debugPrint('Link pressed');
  }
}
