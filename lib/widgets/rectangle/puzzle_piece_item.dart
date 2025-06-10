// widgets/rectangle/puzzle_piece_item.dart

import 'package:flutter/material.dart';
import '../../config/constants/layout.dart';
import '../../models/tag.dart';

/// A puzzle piece item that can be edited and dragged, with interlocking puzzle piece shape
class PuzzlePieceItem extends StatefulWidget {
  final double width;
  final double height;
  final TagData rectangle;
  final int pieceIndex; // Index of this piece (0-6)
  final int totalPieces; // Total number of pieces (7)
  final VoidCallback? onTap;
  final Function(String) onRename;
  final bool isCompact;

  const PuzzlePieceItem({
    super.key,
    required this.width,
    required this.height,
    required this.rectangle,
    required this.pieceIndex,
    required this.totalPieces,
    this.onTap,
    required this.onRename,
    this.isCompact = false,
  });

  @override
  State<PuzzlePieceItem> createState() => _PuzzlePieceItemState();
}

class _PuzzlePieceItemState extends State<PuzzlePieceItem> {
  bool _isEditing = false;
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.rectangle.label);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _saveChanges();
    }
  }

  void _saveChanges() {
    final newLabel = _textController.text.trim();
    if (newLabel.isNotEmpty && newLabel != widget.rectangle.label) {
      widget.onRename(newLabel);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textController.text = widget.rectangle.label;
    });
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.rectangle.isSelected;
    final borderWidth = isSelected
        ? (widget.isCompact ? 1.5 : 2.0)
        : (widget.isCompact ? 1.0 : 1.2);

    if (_isEditing) {
      return _buildEditingMode(theme, borderWidth);
    } else {
      return _buildNormalMode(theme, isSelected, borderWidth);
    }
  }

  Widget _buildEditingMode(ThemeData theme, double borderWidth) {
    return ClipPath(
      clipper: PuzzlePieceClipper(
        pieceIndex: widget.pieceIndex,
        totalPieces: widget.totalPieces,
        width: widget.width,
        height: widget.height,
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.2),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.6),
            width: borderWidth + 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: widget.isCompact ? 14.0 : 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: '${_textController.text.length}/3',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    fontSize: (widget.isCompact ? 14.0 : 16.0) * 0.8,
                  ),
                ),
                onSubmitted: (_) => _saveChanges(),
                onChanged: (text) {
                  setState(() {});
                },
                maxLines: 1,
                maxLength: 3,
                buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalMode(
      ThemeData theme, bool isSelected, double borderWidth) {
    return Draggable<TagData>(
      data: widget.rectangle,
      feedback: Material(
        elevation: 4.0,
        child: ClipPath(
          clipper: PuzzlePieceClipper(
            pieceIndex: widget.pieceIndex,
            totalPieces: widget.totalPieces,
            width: widget.width * 1.1,
            height: widget.height * 1.1,
          ),
          child: Container(
            width: widget.width * 1.1,
            height: widget.height * 1.1,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.9),
            ),
            child: Center(
              child: _buildSpecialText(
                widget.rectangle.label,
                Colors.white,
                widget.isCompact ? 14.0 : 16.0,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildPuzzlePieceContent(theme, isSelected, borderWidth),
      ),
      child: _buildPuzzlePieceContent(theme, isSelected, borderWidth),
    );
  }

  Widget _buildPuzzlePieceContent(
      ThemeData theme, bool isSelected, double borderWidth) {
    return Semantics(
      label: widget.rectangle.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _startEditing,
        child: ClipPath(
          clipper: PuzzlePieceClipper(
            pieceIndex: widget.pieceIndex,
            totalPieces: widget.totalPieces,
            width: widget.width,
            height: widget.height,
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : theme.colorScheme.primary.withOpacity(0.05),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.primary.withOpacity(0.15),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                splashColor: theme.colorScheme.primary.withOpacity(0.15),
                highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Center(
                  child: _buildSpecialText(
                    widget.rectangle.label,
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.8),
                    widget.isCompact ? 12.0 : 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the special text layout: first character twice as large,
  /// other two characters half size and stacked vertically to the right
  Widget _buildSpecialText(String text, Color color, double baseFontSize) {
    // Ensure we have at least 1 character, pad with spaces if needed
    final paddedText = text.padRight(3, ' ');
    final firstChar = paddedText[0];
    final secondChar = paddedText.length > 1 ? paddedText[1] : ' ';
    final thirdChar = paddedText.length > 2 ? paddedText[2] : ' ';

    final largeFontSize = baseFontSize * 1.5; // First character size
    final smallFontSize =
        baseFontSize * 0.75; // Second and third character size

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // First character (large)
        Text(
          firstChar,
          style: TextStyle(
            color: color,
            fontSize: largeFontSize,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),

        // Small spacing between first and other characters
        const SizedBox(width: 2),

        // Second and third characters (small, stacked vertically)
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              secondChar,
              style: TextStyle(
                color: color,
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            Text(
              thirdChar,
              style: TextStyle(
                color: color,
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom clipper to create puzzle piece shapes
class PuzzlePieceClipper extends CustomClipper<Path> {
  final int pieceIndex;
  final int totalPieces;
  final double width;
  final double height;

  PuzzlePieceClipper({
    required this.pieceIndex,
    required this.totalPieces,
    required this.width,
    required this.height,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // Tab/blank size (about 20% of height)
    final tabSize = size.height * 0.2;
    final tabWidth = tabSize * 0.8;

    // Start from top-left
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(size.width, 0);

    // Right edge with tab or blank
    if (pieceIndex < totalPieces - 1) {
      // Not the last piece, add a tab on the right
      final tabCenter = size.height / 2;
      path.lineTo(size.width, tabCenter - tabSize / 2);

      // Create tab (semicircular protrusion)
      path.arcToPoint(
        Offset(size.width + tabWidth, tabCenter),
        radius: Radius.circular(tabSize / 2),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(size.width, tabCenter + tabSize / 2),
        radius: Radius.circular(tabSize / 2),
        clockwise: false,
      );

      path.lineTo(size.width, size.height);
    } else {
      // Last piece, flat right edge
      path.lineTo(size.width, size.height);
    }

    // Bottom edge
    path.lineTo(0, size.height);

    // Left edge with blank or flat
    if (pieceIndex > 0) {
      // Not the first piece, add a blank on the left
      final blankCenter = size.height / 2;
      path.lineTo(0, blankCenter + tabSize / 2);

      // Create blank (semicircular indentation)
      path.arcToPoint(
        Offset(-tabWidth, blankCenter),
        radius: Radius.circular(tabSize / 2),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(0, blankCenter - tabSize / 2),
        radius: Radius.circular(tabSize / 2),
        clockwise: false,
      );

      path.lineTo(0, 0);
    } else {
      // First piece, flat left edge
      path.lineTo(0, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is! PuzzlePieceClipper ||
        oldClipper.pieceIndex != pieceIndex ||
        oldClipper.totalPieces != totalPieces ||
        oldClipper.width != width ||
        oldClipper.height != height;
  }
}
