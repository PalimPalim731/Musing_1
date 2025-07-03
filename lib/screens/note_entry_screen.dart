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

/// Data structure to hold category-specific note state
class CategoryNoteState {
  final TextEditingController headerController;
  final List<TextEditingController>
      noteControllers; // Changed to support multiple blocks
  final List<FocusNode> noteFocusNodes; // Focus nodes for each note block
  final List<TagData> appliedQuickTags;
  final List<TagData> appliedRegularTags;
  final String category; // Add category parameter

  CategoryNoteState({
    required this.headerController,
    required this.noteControllers,
    required this.noteFocusNodes,
    required this.category, // Make category required
    List<TagData>? appliedQuickTags,
    List<TagData>? appliedRegularTags,
  })  : appliedQuickTags = appliedQuickTags ?? [],
        appliedRegularTags = appliedRegularTags ?? [];

  /// Create a copy with updated values
  CategoryNoteState copyWith({
    TextEditingController? headerController,
    List<TextEditingController>? noteControllers,
    List<FocusNode>? noteFocusNodes,
    String? category,
    List<TagData>? appliedQuickTags,
    List<TagData>? appliedRegularTags,
  }) {
    return CategoryNoteState(
      headerController: headerController ?? this.headerController,
      noteControllers: noteControllers ?? this.noteControllers,
      noteFocusNodes: noteFocusNodes ?? this.noteFocusNodes,
      category: category ?? this.category,
      appliedQuickTags: appliedQuickTags ?? List.from(this.appliedQuickTags),
      appliedRegularTags:
          appliedRegularTags ?? List.from(this.appliedRegularTags),
    );
  }

  /// Get max quick-tags for this category
  int get maxQuickTags {
    switch (category) {
      case 'Circle':
        return 14; // Increased limit for Circle category
      case 'Private':
        return 1; // Limited to 1 quick-tag for Private category
      case 'Public':
      default:
        return 3; // Keep original limit for Public category
    }
  }

  /// Get max regular-tags for this category (unchanged)
  int get maxRegularTags => 3;

  /// Check if this note state has any content
  bool get hasContent =>
      headerController.text.isNotEmpty ||
      noteControllers.any((controller) => controller.text.isNotEmpty) ||
      appliedQuickTags.isNotEmpty ||
      appliedRegularTags.isNotEmpty;

  /// Get total number of applied tags
  int get totalTagCount => appliedQuickTags.length + appliedRegularTags.length;

  /// Check if quick-tag limit is reached (now category-specific)
  bool get isQuickTagLimitReached => appliedQuickTags.length >= maxQuickTags;

  /// Check if regular tag limit is reached
  bool get isRegularTagLimitReached =>
      appliedRegularTags.length >= maxRegularTags;

  /// Check if any tag limit is reached
  bool get isAnyTagLimitReached =>
      isQuickTagLimitReached || isRegularTagLimitReached;

  /// Get remaining quick-tag slots (now category-specific)
  int get remainingQuickTagSlots => maxQuickTags - appliedQuickTags.length;

  /// Get remaining regular tag slots
  int get remainingRegularTagSlots =>
      maxRegularTags - appliedRegularTags.length;
}

/// Main screen for note entry and management with category-specific note layers
class NoteEntryScreen extends StatefulWidget {
  const NoteEntryScreen({super.key});

  @override
  State<NoteEntryScreen> createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  // Maximum number of note blocks per category
  static const int maxNoteBlocks = 3;

  /// Get max quick-tags for a specific category
  int _getMaxQuickTags(String category) {
    switch (category) {
      case 'Circle':
        return 14; // Increased limit for Circle category
      case 'Private':
        return 1; // Limited to 1 quick-tag for Private category
      case 'Public':
      default:
        return 3; // Keep original limit for Public category
    }
  }

  /// Get max regular-tags for a specific category (unchanged)
  int _getMaxRegularTags(String category) => 3;

  // Active category selection
  String _selectedCategory = 'Private';

  // Category-specific note states - each category has its own note layer
  late final Map<String, CategoryNoteState> _categoryNoteStates;

  // Services for data operations
  final NoteService _noteService = NoteService();
  final TagService _tagService = TagService();
  final RectangleService _rectangleService = RectangleService();

  // Focus node to manage keyboard focus
  final FocusNode _noteFocusNode = FocusNode();

  // Track current tag page
  late int _currentTagPage;

  // Track current quick-tag page
  late int _currentQuickTagPage;

  // Getter for current category's note state
  CategoryNoteState get _currentNoteState =>
      _categoryNoteStates[_selectedCategory]!;

  // Getters for current category's data (for easier access)
  TextEditingController get _headerController =>
      _currentNoteState.headerController;
  List<TextEditingController> get _noteControllers =>
      _currentNoteState.noteControllers;
  List<FocusNode> get _noteFocusNodes => _currentNoteState.noteFocusNodes;
  List<TagData> get _appliedQuickTags => _currentNoteState.appliedQuickTags;
  List<TagData> get _appliedRegularTags => _currentNoteState.appliedRegularTags;

  @override
  void initState() {
    super.initState();

    // Initialize category-specific note states with category parameter
    _categoryNoteStates = {
      'Private': CategoryNoteState(
        headerController: TextEditingController(),
        noteControllers: [TextEditingController()], // Start with one note block
        noteFocusNodes: [FocusNode()], // Start with one focus node
        category: 'Private',
      ),
      'Circle': CategoryNoteState(
        headerController: TextEditingController(),
        noteControllers: [TextEditingController()], // Start with one note block
        noteFocusNodes: [FocusNode()], // Start with one focus node
        category: 'Circle',
      ),
      'Public': CategoryNoteState(
        headerController: TextEditingController(),
        noteControllers: [TextEditingController()], // Start with one note block
        noteFocusNodes: [FocusNode()], // Start with one focus node
        category: 'Public',
      ),
    };

    // Initialize current tag page
    _currentTagPage = _tagService.currentPage;

    // Initialize current quick-tag page
    _currentQuickTagPage = _rectangleService.currentPage;

    // Listen to tag changes (like renames) to update applied tags
    _tagService.tagsStream.listen((updatedTags) {
      _updateAppliedTagsFromService();
    });

    // Listen to rectangle changes (like renames) to update applied quick-tags
    _rectangleService.rectanglesStream.listen((updatedRectangles) {
      _updateAppliedQuickTagsFromService();
    });

    // Listen to tag page changes
    _tagService.pageStream.listen((newPage) {
      setState(() {
        _currentTagPage = newPage;
      });
    });

    // Listen to tag category changes to update UI
    _tagService.categoryStream.listen((newActiveCategory) {
      setState(() {}); // Trigger UI update
    });

    // Listen to rectangle page changes
    _rectangleService.pageStream.listen((newPage) {
      setState(() {
        _currentQuickTagPage = newPage;
      });
    });

    // Listen to rectangle category changes to update UI
    _rectangleService.categoryStream.listen((newActiveCategory) {
      setState(() {}); // Trigger UI update
    });
  }

  @override
  void dispose() {
    // Clean up all controllers and focus nodes
    for (var categoryState in _categoryNoteStates.values) {
      categoryState.headerController.dispose();
      for (var controller in categoryState.noteControllers) {
        controller.dispose();
      }
      for (var focusNode in categoryState.noteFocusNodes) {
        focusNode.dispose();
      }
    }
    _noteFocusNode.dispose();
    super.dispose();
  }

  /// Update applied regular tags when service data changes
  void _updateAppliedTagsFromService() {
    bool hasChanges = false;

    for (var category in _categoryNoteStates.keys) {
      final categoryState = _categoryNoteStates[category]!;
      if (categoryState.appliedRegularTags.isNotEmpty) {
        // Get all tags for this specific category
        final allTagsForCategory = _tagService.getAllTagsForCategory(category);

        for (int i = 0; i < categoryState.appliedRegularTags.length; i++) {
          final currentTag = categoryState.appliedRegularTags[i];
          final updatedTag = allTagsForCategory.firstWhere(
            (tag) => tag.id == currentTag.id,
            orElse: () => currentTag,
          );

          if (updatedTag.label != currentTag.label) {
            categoryState.appliedRegularTags[i] = updatedTag;
            hasChanges = true;
          }
        }
      }
    }

    if (hasChanges) {
      setState(() {}); // Trigger UI update
    }
  }

  /// Update applied quick-tags when service data changes
  void _updateAppliedQuickTagsFromService() {
    bool hasChanges = false;

    for (var category in _categoryNoteStates.keys) {
      final categoryState = _categoryNoteStates[category]!;
      if (categoryState.appliedQuickTags.isNotEmpty) {
        // Get all rectangles for this specific category
        final allRectanglesForCategory =
            _rectangleService.getAllRectanglesForCategory(category);

        for (int i = 0; i < categoryState.appliedQuickTags.length; i++) {
          final currentTag = categoryState.appliedQuickTags[i];
          final updatedRectangle = allRectanglesForCategory.firstWhere(
            (rectangle) => rectangle.id == currentTag.id,
            orElse: () => currentTag,
          );

          if (updatedRectangle.label != currentTag.label) {
            categoryState.appliedQuickTags[i] = updatedRectangle;
            hasChanges = true;
          }
        }
      }
    }

    if (hasChanges) {
      setState(() {}); // Trigger UI update
    }
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
                              headerController: _headerController,
                              noteControllers: _noteControllers,
                              headerFocusNode: null,
                              noteFocusNodes: _noteFocusNodes
                                  .map((fn) => fn as FocusNode?)
                                  .toList(),
                              appliedQuickTags: _appliedQuickTags,
                              appliedRegularTags: _appliedRegularTags,
                              selectedCategory: _selectedCategory,
                              onTagAdded: _handleTagAdded,
                              onTagRemoved: _handleTagRemoved,
                              onAddNoteBlock: _handleAddNoteBlock,
                              onRemoveNoteBlock: _handleRemoveNoteBlock,
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
    if (category == _selectedCategory) return; // No change needed

    debugPrint('Switching from $_selectedCategory to $category category');

    // Log current state before switching
    final currentState = _currentNoteState;
    if (currentState.hasContent) {
      debugPrint(
          'Preserving $category note with ${currentState.headerController.text.length + currentState.noteControllers.map((c) => c.text.length).reduce((a, b) => a + b)} characters and ${currentState.totalTagCount} tags');
    }

    setState(() {
      _selectedCategory = category;
    });

    // Switch both tag service and rectangle service to this category's sets
    _tagService.switchCategory(category);
    _rectangleService.switchCategory(category);

    // Log new state after switching
    final newState = _currentNoteState;
    if (newState.hasContent) {
      debugPrint(
          'Loaded $category note with ${newState.headerController.text.length + newState.noteControllers.map((c) => c.text.length).reduce((a, b) => a + b)} characters and ${newState.totalTagCount} tags');
    } else {
      debugPrint('Loaded empty $category note space');
    }
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

  // Handle adding a new note block
  void _handleAddNoteBlock() {
    // Check if we've reached the maximum number of blocks
    if (_noteControllers.length >= maxNoteBlocks) {
      debugPrint(
          'Cannot add more note blocks. Maximum limit ($maxNoteBlocks) reached for $_selectedCategory category.');

      // Show a brief feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $maxNoteBlocks note blocks allowed'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      final currentState = _currentNoteState;
      currentState.noteControllers.add(TextEditingController());
      currentState.noteFocusNodes.add(FocusNode());
    });
    debugPrint(
        'Added note block to $_selectedCategory category. Total blocks: ${_noteControllers.length}/$maxNoteBlocks');
  }

  // Handle removing the most recent note block
  void _handleRemoveNoteBlock() {
    if (_noteControllers.length <= 1) {
      return; // Don't remove if only one block remains
    }

    setState(() {
      final currentState = _currentNoteState;
      // Remove and dispose the last controller and focus node
      final removedController = currentState.noteControllers.removeLast();
      final removedFocusNode = currentState.noteFocusNodes.removeLast();

      removedController.dispose();
      removedFocusNode.dispose();
    });

    debugPrint(
        'Removed note block from $_selectedCategory category. Total blocks: ${_noteControllers.length}/$maxNoteBlocks');
  }

  // Determine if a tag is a quick-tag (rectangle) based on ID
  bool _isQuickTag(TagData tag) {
    final id = int.tryParse(tag.id) ?? 0;
    return id >= 101; // Rectangle IDs start from 101
  }

  // Handle tag dropped onto the note with limit validation
  void _handleTagAdded(TagData tag) {
    final currentState = _currentNoteState;

    if (_isQuickTag(tag)) {
      // Check if tag is already applied or limit is reached
      if (_appliedQuickTags.any((t) => t.id == tag.id) ||
          currentState.isQuickTagLimitReached) {
        return;
      }

      // Add to current category's quick-tags
      setState(() {
        _appliedQuickTags.add(tag);
      });

      debugPrint(
          'Quick-tag added to $_selectedCategory note: ${tag.label} (${_appliedQuickTags.length}/${currentState.maxQuickTags})');
    } else {
      // Check if tag is already applied or limit is reached
      if (_appliedRegularTags.any((t) => t.id == tag.id) ||
          currentState.isRegularTagLimitReached) {
        return;
      }

      // Add to current category's regular-tags
      setState(() {
        _appliedRegularTags.add(tag);
      });

      debugPrint(
          'Regular-tag added to $_selectedCategory note: ${tag.label} (${_appliedRegularTags.length}/${currentState.maxRegularTags})');
    }
  }

  // Handle removal of tag from the note
  void _handleTagRemoved(TagData tag) {
    setState(() {
      if (_isQuickTag(tag)) {
        _appliedQuickTags.removeWhere((t) => t.id == tag.id);
        debugPrint(
            'Quick-tag removed from $_selectedCategory note: ${tag.label} (${_appliedQuickTags.length}/${_currentNoteState.maxQuickTags})');
      } else {
        _appliedRegularTags.removeWhere((t) => t.id == tag.id);
        debugPrint(
            'Regular-tag removed from $_selectedCategory note: ${tag.label} (${_appliedRegularTags.length}/${_currentNoteState.maxRegularTags})');
      }
    });
  }

  // Handler methods for bottom bar actions
  void _handleSettingsPressed() {
    // TODO: Implement settings navigation
    debugPrint('Settings pressed');
  }

  void _handleExplorePressed() {
    // Save the current note first if needed
    _saveCurrentNote();

    // TODO: Navigate to explore screen
    debugPrint('Explore pressed');
  }

  void _handleProfilePressed() {
    // TODO: Implement profile navigation
    debugPrint('Profile pressed');
  }

  // Save the current note (combines both tag types) with validation
  void _saveCurrentNote() {
    final headerContent = _headerController.text.trim();

    // Combine all note block contents
    final noteContents = _noteControllers
        .map((controller) => controller.text.trim())
        .where((content) => content.isNotEmpty)
        .toList();

    final noteContent = noteContents.join('\n\n');

    // Combine header and note content with a separator if both exist
    String fullContent = '';
    if (headerContent.isNotEmpty && noteContent.isNotEmpty) {
      fullContent = '$headerContent\n\n$noteContent';
    } else if (headerContent.isNotEmpty) {
      fullContent = headerContent;
    } else if (noteContent.isNotEmpty) {
      fullContent = noteContent;
    }

    if (fullContent.isEmpty &&
        _appliedQuickTags.isEmpty &&
        _appliedRegularTags.isEmpty) {
      return; // Nothing to save
    }

    // Validate tag limits before saving (now category-specific)
    final maxQuickTags = _getMaxQuickTags(_selectedCategory);
    final maxRegularTags = _getMaxRegularTags(_selectedCategory);

    if (_appliedQuickTags.length > maxQuickTags ||
        _appliedRegularTags.length > maxRegularTags) {
      debugPrint('Tag limits exceeded - save aborted');
      return;
    }

    // Combine all applied tag IDs (both quick-tags and regular-tags)
    final allTagIds = [
      ..._appliedQuickTags.map((tag) => tag.id),
      ..._appliedRegularTags.map((tag) => tag.id),
    ];

    // Call the note service to save the note
    _noteService
        .addNote(
      content: fullContent,
      category: _selectedCategory,
      tagIds: allTagIds,
      size: 'Medium', // Default size for notes
    )
        .then((note) {
      debugPrint('Note saved to $_selectedCategory: ${note.id}');
      debugPrint(
          'Header: ${headerContent.isNotEmpty ? '"$headerContent"' : '(empty)'}');
      debugPrint('Content blocks: ${noteContents.length}');
      debugPrint(
          'Quick-tags (${_appliedQuickTags.length}/$maxQuickTags): ${_appliedQuickTags.map((t) => t.label).join(", ")}');
      debugPrint(
          'Regular-tags (${_appliedRegularTags.length}/$maxRegularTags): ${_appliedRegularTags.map((t) => t.label).join(", ")}');

      // Clear the current category's note input and reset state
      _headerController.clear();
      for (var controller in _noteControllers) {
        controller.clear();
      }

      setState(() {
        _appliedQuickTags.clear();
        _appliedRegularTags.clear();
      });
    });
  }

  // Centralized note action handlers
  void _handleDeleteNote() {
    final currentState = _currentNoteState;
    if (!currentState.hasContent) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $_selectedCategory note?'),
        content: Text(
            'Are you sure you want to delete this $_selectedCategory note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _headerController.clear();
              for (var controller in _noteControllers) {
                controller.clear();
              }
              Navigator.of(context).pop();

              // Reset current category's applied tags
              setState(() {
                _appliedQuickTags.clear();
                _appliedRegularTags.clear();
              });

              debugPrint('$_selectedCategory note deleted');
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _handleUndoNote() {
    debugPrint('Undo pressed for $_selectedCategory note');
    // TODO: Implement undo functionality per category
  }

  void _handleFormatNote() {
    debugPrint(
        'Format pressed for $_selectedCategory note - Feature to be implemented later');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text formatting options coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCameraPressed() {
    debugPrint('Camera pressed for $_selectedCategory note');
    // TODO: Implement camera functionality per category
  }

  void _handleMicPressed() {
    debugPrint('Mic pressed for $_selectedCategory note');
    // TODO: Implement voice recording functionality per category
  }

  void _handleLinkPressed() {
    debugPrint('Link pressed for $_selectedCategory note');
    // TODO: Implement link functionality per category
  }
}
