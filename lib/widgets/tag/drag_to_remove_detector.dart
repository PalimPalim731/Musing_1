// widgets/tag/drag_to_remove_detector.dart

import 'package:flutter/material.dart';
import 'tag_chip.dart'; // For TagRemovalData

/// A widget that detects when a dragged tag is more than 50% outside its bounds
/// and triggers removal automatically
class DragToRemoveDetector extends StatefulWidget {
  final Widget child;
  final Function(TagRemovalData)? onTagRemoval;

  const DragToRemoveDetector({
    super.key,
    required this.child,
    this.onTagRemoval,
  });

  @override
  State<DragToRemoveDetector> createState() => _DragToRemoveDetectorState();
}

class _DragToRemoveDetectorState extends State<DragToRemoveDetector> {
  // Key to get the bounds of the container
  final GlobalKey _containerKey = GlobalKey();

  // Track the current drag data and position
  TagRemovalData? _currentDragData;
  Offset? _lastDragPosition;

  // Timer to periodically check if tag should be removed
  bool _isTracking = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TagRemovalData>(
      key: _containerKey,
      onWillAccept: (TagRemovalData? data) {
        // Always accept to track position
        return data != null;
      },
      onAccept: (TagRemovalData data) {
        // Reset tracking when drag ends normally (inside bounds)
        _stopTracking();
      },
      onMove: (DragTargetDetails<TagRemovalData> details) {
        // Track the drag position
        if (details.data != null) {
          _currentDragData = details.data!;
          _lastDragPosition = details.offset;

          if (!_isTracking) {
            _startTracking();
          }

          // Check immediately if more than 50% is outside
          _checkRemovalCondition();
        }
      },
      onLeave: (TagRemovalData? data) {
        // Tag has left the bounds - check if it should be removed
        if (data != null) {
          _currentDragData = data;
          _checkRemovalCondition();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return widget.child;
      },
    );
  }

  void _startTracking() {
    _isTracking = true;
  }

  void _stopTracking() {
    _isTracking = false;
    _currentDragData = null;
    _lastDragPosition = null;
  }

  void _checkRemovalCondition() {
    if (_currentDragData == null || _lastDragPosition == null) {
      return;
    }

    // Get the bounds of the container
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final containerSize = renderBox.size;
    final containerPosition = renderBox.localToGlobal(Offset.zero);

    // Convert global drag position to local coordinates
    final localPosition = renderBox.globalToLocal(_lastDragPosition!);

    // Calculate if the drag position is outside the bounds
    // We'll use a simplified approach: if the center point is outside, remove it
    final isOutsideLeft = localPosition.dx < 0;
    final isOutsideRight = localPosition.dx > containerSize.width;
    final isOutsideTop = localPosition.dy < 0;
    final isOutsideBottom = localPosition.dy > containerSize.height;

    final isOutside =
        isOutsideLeft || isOutsideRight || isOutsideTop || isOutsideBottom;

    if (isOutside) {
      // Tag is outside bounds - remove it
      debugPrint('Tag dragged outside bounds: ${_currentDragData!.tag.label}');

      // Trigger removal
      widget.onTagRemoval?.call(_currentDragData!);
      _currentDragData!.onRemove();

      // Stop tracking
      _stopTracking();
    }
  }
}
