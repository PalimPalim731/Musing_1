// widgets/rectangle/rectangle_bar.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';
import '../../services/rectangle_service.dart';
import 'rectangle_item.dart';

/// Bar containing 7 rectangles positioned above the note area
class RectangleBar extends StatefulWidget {
  final bool isCompact;
  final Function(TagData)? onRectangleSelected;

  const RectangleBar({
    super.key,
    this.isCompact = false,
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
    _rectangles = _rectangleService.getAllRectangles();

    // Listen to rectangle changes (like renames)
    _rectangleService.rectanglesStream.listen((updatedRectangles) {
      setState(() {
        _rectangles = updatedRectangles;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions
    final availableHeight = AppLayout.selectorHeight + (AppLayout.spacingS * 2);
    final spacing = widget.isCompact ? AppLayout.spacingXS : AppLayout.spacingS;

    return Container(
      height: availableHeight,
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate rectangle dimensions
          final totalSpacing = spacing * (_rectangles.length - 1);
          final availableWidth = constraints.maxWidth - totalSpacing;
          final rectangleWidth = availableWidth / _rectangles.length;
          final rectangleHeight = constraints.maxHeight - (spacing * 2);

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
                  onRename: (newLabel) => _handleRectangleRename(
                      _rectangles[rectangleIndex], newLabel),
                  isCompact: widget.isCompact,
                );
              } else {
                return SizedBox(width: spacing);
              }
            }),
          );
        },
      ),
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
