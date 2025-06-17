// widgets/rectangle/rectangle_bar.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../../services/rectangle_service.dart';
import 'rectangle_item.dart';

/// Bar containing rectangles positioned above the note area
/// Private/Circle: 7 rectangles horizontally
/// Public: 6 rectangles in 2x3 grid
class RectangleBar extends StatefulWidget {
  final bool isCompact;
  final String selectedCategory; // Add category parameter
  final Function(TagData)? onRectangleSelected;

  const RectangleBar({
    super.key,
    this.isCompact = false,
    this.selectedCategory = 'Private', // Default to Private
    this.onRectangleSelected,
  });

  @override
  State<RectangleBar> createState() => _RectangleBarState();
}

class _RectangleBarState extends State<RectangleBar> {
  final RectangleService _rectangleService = RectangleService();
  late List<TagData> _rectangles;

  @override
  void initState() {
    super.initState();
    _rectangles = _rectangleService.getCurrentPageRectangles();

    // Listen to rectangle changes (like renames)
    _rectangleService.rectanglesStream.listen((updatedRectangles) {
      setState(() {
        _rectangles = updatedRectangles;
      });
    });

    // Listen to page changes
    _rectangleService.pageStream.listen((newPage) {
      setState(() {
        _rectangles = _rectangleService.getCurrentPageRectangles();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions
    final availableHeight = AppLayout.selectorHeight + (AppLayout.spacingS * 2);
    final spacing = widget.isCompact ? AppLayout.spacingXS : AppLayout.spacingS;
    final isCircleCategory = widget.selectedCategory == 'Circle';
    final isPublicCategory = widget.selectedCategory == 'Public';

    return Container(
      height: availableHeight,
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate rectangle dimensions
          final rectangleHeight = constraints.maxHeight - (spacing * 2);

          if (isPublicCategory) {
            // Public category: 6 horizontally-long rectangles in 2x3 grid
            return _buildGridRectangles(constraints, rectangleHeight, spacing);
          } else if (isCircleCategory) {
            // Circle category: joined rectangles with no spacing
            return _buildJoinedRectangles(
                context, constraints, rectangleHeight);
          } else {
            // Private category: separated rectangles with spacing
            return _buildSeparatedRectangles(
                constraints, rectangleHeight, spacing);
          }
        },
      ),
    );
  }

  Widget _buildGridRectangles(
      BoxConstraints constraints, double rectangleHeight, double spacing) {
    // 2x3 grid layout for Public category
    final rowSpacing = spacing * 0.5; // Narrow spacing between rows
    final columnSpacing = spacing; // Normal spacing between columns

    // Calculate dimensions for 2 rows and 3 columns
    final availableHeight =
        rectangleHeight - rowSpacing; // Height minus row spacing
    final availableWidth = constraints.maxWidth -
        (columnSpacing * 2); // Width minus column spacing

    final itemHeight = availableHeight / 2; // Split height between 2 rows
    final itemWidth = availableWidth / 3; // Split width between 3 columns

    return Column(
      children: [
        // First row (rectangles 0, 1, 2)
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: columnSpacing),
                Expanded(
                  child: RectangleItem(
                    width: itemWidth,
                    height: itemHeight,
                    rectangle: _rectangles[i],
                    onTap: () => _handleRectangleTap(_rectangles[i]),
                    onRename: (newLabel) =>
                        _handleRectangleRename(_rectangles[i], newLabel),
                    isCompact: widget.isCompact,
                    isJoined: false,
                    isHorizontal:
                        true, // New parameter for horizontal rectangles
                    maxCharacters: 10, // New parameter for 10-character limit
                  ),
                ),
              ],
            ],
          ),
        ),

        // Spacing between rows
        SizedBox(height: rowSpacing),

        // Second row (rectangles 3, 4, 5)
        Expanded(
          child: Row(
            children: [
              for (int i = 3; i < 6; i++) ...[
                if (i > 3) SizedBox(width: columnSpacing),
                Expanded(
                  child: RectangleItem(
                    width: itemWidth,
                    height: itemHeight,
                    rectangle: _rectangles[i],
                    onTap: () => _handleRectangleTap(_rectangles[i]),
                    onRename: (newLabel) =>
                        _handleRectangleRename(_rectangles[i], newLabel),
                    isCompact: widget.isCompact,
                    isJoined: false,
                    isHorizontal:
                        true, // New parameter for horizontal rectangles
                    maxCharacters: 10, // New parameter for 10-character limit
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinedRectangles(BuildContext context,
      BoxConstraints constraints, double rectangleHeight) {
    final theme = Theme.of(context);

    // For joined rectangles, use all available width
    final totalWidth = constraints.maxWidth;
    final rectangleWidth = totalWidth / _rectangles.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
        // Use much lighter shadow to match Private category appearance
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Reduced from 0.1 to 0.05
            blurRadius: 2, // Reduced from 4 to 2
            offset: const Offset(0, 1), // Reduced from (0, 2) to (0, 1)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
        child: Row(
          children: List.generate(_rectangles.length, (index) {
            final rectangle = _rectangles[index];
            final isFirst = index == 0;
            final isLast = index == _rectangles.length - 1;

            return Container(
              width: rectangleWidth,
              height: rectangleHeight,
              decoration: BoxDecoration(
                // Use much lighter divider lines to match Private category
                border: Border(
                  right: isLast
                      ? BorderSide.none
                      : BorderSide(
                          color: theme.colorScheme.primary
                              .withOpacity(0.15), // Reduced from 0.3 to 0.15
                          width: 1.0, // Reduced from 1.5 to 1.0
                        ),
                ),
              ),
              child: RectangleItem(
                width: rectangleWidth,
                height: rectangleHeight,
                rectangle: rectangle,
                onTap: () => _handleRectangleTap(rectangle),
                onRename: (newLabel) =>
                    _handleRectangleRename(rectangle, newLabel),
                isCompact: widget.isCompact,
                isJoined: true, // New parameter to indicate joined style
                isFirst: isFirst,
                isLast: isLast,
                maxCharacters: 3, // Circle category uses 3-character limit
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSeparatedRectangles(
      BoxConstraints constraints, double rectangleHeight, double spacing) {
    // Calculate rectangle dimensions for separated layout
    final totalSpacing = spacing * (_rectangles.length - 1);
    final availableWidth = constraints.maxWidth - totalSpacing;
    final rectangleWidth = availableWidth / _rectangles.length;

    // Ensure height > width (portrait orientation)
    final adjustedWidth = rectangleHeight > rectangleWidth
        ? rectangleWidth
        : rectangleHeight * 0.7; // Make width 70% of height if needed

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_rectangles.length * 2 - 1, (index) {
        // Even indices are rectangles, odd indices are spacers
        if (index.isEven) {
          final rectangleIndex = index ~/ 2;
          return RectangleItem(
            width: adjustedWidth,
            height: rectangleHeight,
            rectangle: _rectangles[rectangleIndex],
            onTap: () => _handleRectangleTap(_rectangles[rectangleIndex]),
            onRename: (newLabel) =>
                _handleRectangleRename(_rectangles[rectangleIndex], newLabel),
            isCompact: widget.isCompact,
            isJoined: false, // Separated style
            maxCharacters: 3, // Private category uses 3-character limit
          );
        } else {
          return SizedBox(width: spacing);
        }
      }),
    );
  }

  void _handleRectangleTap(TagData rectangle) {
    widget.onRectangleSelected?.call(rectangle);
  }

  void _handleRectangleRename(TagData rectangle, String newLabel) {
    _rectangleService
        .updateRectangle(rectangle.id, newLabel)
        .then((updatedRectangle) {
      if (updatedRectangle != null) {
        // Service will broadcast changes to its stream,
        // which we're already listening to in initState
        debugPrint('Rectangle renamed: ${rectangle.label} → $newLabel');
      }
    });
  }
}
