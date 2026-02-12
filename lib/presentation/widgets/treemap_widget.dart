import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vdiskusage/core/consts/app_constants.dart';
import 'package:vdiskusage/core/icons/file_type_icons.dart';
import 'package:vdiskusage/core/utils/file_size_formatter.dart';
import 'package:vdiskusage/domain/entities/file_node.dart';

/// Interactive Squarified Treemap widget using CustomPainter for performance.
class TreemapWidget extends StatefulWidget {
  final FileNode node;
  final ValueChanged<int>? onNodeTap;
  final ValueChanged<int>? onNodeDoubleTap;

  const TreemapWidget({
    super.key,
    required this.node,
    this.onNodeTap,
    this.onNodeDoubleTap,
  });

  @override
  State<TreemapWidget> createState() => _TreemapWidgetState();
}

class _TreemapWidgetState extends State<TreemapWidget> {
  int? _hoveredIndex;
  List<_TreemapRect> _rects = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _rects = _computeTreemap(
          widget.node.childrenSortedBySize,
          Rect.fromLTWH(0, 0, size.width, size.height),
        );

        return MouseRegion(
          onHover: (event) {
            final index = _hitTest(event.localPosition);
            if (index != _hoveredIndex) {
              setState(() => _hoveredIndex = index);
            }
          },
          onExit: (_) {
            if (_hoveredIndex != null) {
              setState(() => _hoveredIndex = null);
            }
          },
          child: GestureDetector(
            onTapUp: (details) {
              final index = _hitTest(details.localPosition);
              if (index != null) widget.onNodeTap?.call(index);
            },
            onDoubleTapDown: (details) {
              final index = _hitTest(details.localPosition);
              if (index != null) widget.onNodeDoubleTap?.call(index);
            },
            child: CustomPaint(
              size: size,
              painter: _TreemapPainter(
                rects: _rects,
                hoveredIndex: _hoveredIndex,
              ),
              child: _hoveredIndex != null
                  ? _buildTooltip(_hoveredIndex!)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTooltip(int index) {
    if (index >= _rects.length) return const SizedBox.shrink();

    final rect = _rects[index];
    final node = rect.node;

    return Positioned(
      left: rect.rect.center.dx.clamp(0, double.infinity),
      top: rect.rect.center.dy.clamp(0, double.infinity),
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                FileSizeFormatter.format(node.totalSize),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _hitTest(Offset position) {
    for (int i = 0; i < _rects.length; i++) {
      if (_rects[i].rect.contains(position)) return i;
    }
    return null;
  }

  /// Squarified Treemap layout algorithm.
  List<_TreemapRect> _computeTreemap(List<FileNode> nodes, Rect bounds) {
    if (nodes.isEmpty || bounds.isEmpty) return [];

    final totalSize = nodes.fold<int>(0, (s, n) => s + n.totalSize);
    if (totalSize <= 0) return [];

    final result = <_TreemapRect>[];
    _squarify(
      nodes: nodes,
      bounds: bounds,
      totalSize: totalSize.toDouble(),
      result: result,
    );
    return result;
  }

  void _squarify({
    required List<FileNode> nodes,
    required Rect bounds,
    required double totalSize,
    required List<_TreemapRect> result,
  }) {
    if (nodes.isEmpty || bounds.width < 1 || bounds.height < 1) return;

    if (nodes.length == 1) {
      final padded = _padRect(bounds);
      if (padded.width > 0 && padded.height > 0) {
        result.add(_TreemapRect(node: nodes[0], rect: padded));
      }
      return;
    }

    // Determine layout direction
    final isHorizontal = bounds.width >= bounds.height;

    // Find the best row split
    double rowArea = 0;
    int split = 0;
    double bestAspect = double.infinity;

    for (int i = 0; i < nodes.length; i++) {
      rowArea += nodes[i].totalSize;
      final fraction = rowArea / totalSize;

      Rect rowBounds;
      if (isHorizontal) {
        rowBounds = Rect.fromLTWH(
          bounds.left,
          bounds.top,
          bounds.width * fraction,
          bounds.height,
        );
      } else {
        rowBounds = Rect.fromLTWH(
          bounds.left,
          bounds.top,
          bounds.width,
          bounds.height * fraction,
        );
      }

      // Calculate worst aspect ratio in this row
      double worstAspect = 0;
      double itemOffset = 0;
      for (int j = 0; j <= i; j++) {
        final itemFraction = nodes[j].totalSize / rowArea;
        Rect itemRect;
        if (isHorizontal) {
          itemRect = Rect.fromLTWH(
            rowBounds.left,
            rowBounds.top + rowBounds.height * itemOffset,
            rowBounds.width,
            rowBounds.height * itemFraction,
          );
        } else {
          itemRect = Rect.fromLTWH(
            rowBounds.left + rowBounds.width * itemOffset,
            rowBounds.top,
            rowBounds.width * itemFraction,
            rowBounds.height,
          );
        }
        itemOffset += itemFraction;

        final ar = itemRect.width > 0 && itemRect.height > 0
            ? math.max(
                itemRect.width / itemRect.height,
                itemRect.height / itemRect.width,
              )
            : double.infinity;
        worstAspect = math.max(worstAspect, ar);
      }

      if (worstAspect < bestAspect) {
        bestAspect = worstAspect;
        split = i + 1;
      } else if (worstAspect > bestAspect * 1.5 && split > 0) {
        break; // Getting worse, stop
      }
    }

    if (split <= 0) split = 1;

    // Layout the row
    final rowNodes = nodes.sublist(0, split);
    final remainNodes = nodes.sublist(split);
    final rowSize =
        rowNodes.fold<int>(0, (s, n) => s + n.totalSize).toDouble();
    final fraction = rowSize / totalSize;

    Rect rowBounds;
    Rect remainBounds;

    if (isHorizontal) {
      final rowWidth = bounds.width * fraction;
      rowBounds = Rect.fromLTWH(
        bounds.left, bounds.top, rowWidth, bounds.height);
      remainBounds = Rect.fromLTWH(
        bounds.left + rowWidth, bounds.top,
        bounds.width - rowWidth, bounds.height);
    } else {
      final rowHeight = bounds.height * fraction;
      rowBounds = Rect.fromLTWH(
        bounds.left, bounds.top, bounds.width, rowHeight);
      remainBounds = Rect.fromLTWH(
        bounds.left, bounds.top + rowHeight,
        bounds.width, bounds.height - rowHeight);
    }

    // Fill row
    double offset = 0;
    for (final node in rowNodes) {
      final itemFraction = rowSize > 0 ? node.totalSize / rowSize : 0.0;
      Rect itemRect;

      if (isHorizontal) {
        itemRect = Rect.fromLTWH(
          rowBounds.left,
          rowBounds.top + rowBounds.height * offset,
          rowBounds.width,
          rowBounds.height * itemFraction,
        );
      } else {
        itemRect = Rect.fromLTWH(
          rowBounds.left + rowBounds.width * offset,
          rowBounds.top,
          rowBounds.width * itemFraction,
          rowBounds.height,
        );
      }
      offset += itemFraction;

      final padded = _padRect(itemRect);
      if (padded.width > AppConstants.treemapMinBlockSize &&
          padded.height > AppConstants.treemapMinBlockSize) {
        result.add(_TreemapRect(node: node, rect: padded));
      }
    }

    // Recurse for remaining
    if (remainNodes.isNotEmpty) {
      final remainSize =
          remainNodes.fold<int>(0, (s, n) => s + n.totalSize).toDouble();
      _squarify(
        nodes: remainNodes,
        bounds: remainBounds,
        totalSize: remainSize,
        result: result,
      );
    }
  }

  Rect _padRect(Rect r) {
    const p = AppConstants.treemapPadding;
    return Rect.fromLTWH(
      r.left + p, r.top + p,
      math.max(0, r.width - p * 2),
      math.max(0, r.height - p * 2),
    );
  }
}

class _TreemapRect {
  final FileNode node;
  final Rect rect;

  const _TreemapRect({required this.node, required this.rect});
}

class _TreemapPainter extends CustomPainter {
  final List<_TreemapRect> rects;
  final int? hoveredIndex;

  const _TreemapPainter({required this.rects, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < rects.length; i++) {
      final r = rects[i];
      final isHovered = i == hoveredIndex;
      final color = FileTypeIcons.color(r.node.category);

      // Fill
      final fillPaint = Paint()
        ..color = isHovered
            ? color.withOpacity(0.5)
            : color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        r.rect, const Radius.circular(4));
      canvas.drawRRect(rrect, fillPaint);

      // Border
      final borderPaint = Paint()
        ..color = isHovered
            ? color.withOpacity(0.8)
            : color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? 2.0 : 0.5;

      canvas.drawRRect(rrect, borderPaint);

      // Label (only if rect is big enough)
      if (r.rect.width > 50 && r.rect.height > 30) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: r.node.name,
            style: TextStyle(
              color: Colors.white.withOpacity(isHovered ? 1.0 : 0.8),
              fontSize: math.min(12.0, r.rect.width / 10).clamp(8.0, 12.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        );
        textPainter.layout(maxWidth: r.rect.width - 8);
        textPainter.paint(
          canvas,
          Offset(r.rect.left + 4, r.rect.top + 4),
        );

        // Size label
        if (r.rect.height > 48) {
          final sizePainter = TextPainter(
            text: TextSpan(
              text: FileSizeFormatter.formatCompact(r.node.totalSize),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          sizePainter.layout(maxWidth: r.rect.width - 8);
          sizePainter.paint(
            canvas,
            Offset(r.rect.left + 4, r.rect.top + 20),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreemapPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.rects != rects;
  }
}
