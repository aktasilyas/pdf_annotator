/// Optimized Stroke Painter
///
/// PERFORMANCE OPTIMIZATIONS:
/// 1. Path caching for active strokes (avoid rebuild every frame)
/// 2. Simplified rendering for active highlights (no blend mode)
/// 3. FilterQuality.medium (faster than .high)
/// 4. Simple path for very short strokes (no bezier overhead)
///
/// This eliminates the jitter/shaking issue during drawing.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';

class OptimizedStrokePainter extends CustomPainter {
  final DrawingPage page;

  // ⚡ OPTIMIZATION: Cache active path to avoid rebuilding every frame
  Path? _cachedActivePath;
  int _cachedActivePathPointCount = 0;
  String? _cachedActiveId;

  OptimizedStrokePainter({required this.page}) : super(repaint: page);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw cached bitmap (high res, scaled down)
    if (page.cachedBitmap != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        page.cachedBitmap!.width.toDouble(),
        page.cachedBitmap!.height.toDouble(),
      );
      final dst = Rect.fromLTWH(0, 0, size.width, size.height);

      // ⚡ OPTIMIZATION: medium quality (faster than high)
      canvas.drawImageRect(
        page.cachedBitmap!,
        src,
        dst,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..isAntiAlias = true,
      );
    } else if (page.strokes.isNotEmpty || page.highlights.isNotEmpty) {
      // No cache yet, draw directly (rare case)
      for (final highlight in page.highlights) {
        _drawHighlight(canvas, highlight);
      }
      for (final stroke in page.strokes) {
        _drawStroke(canvas, stroke);
      }
    }

    // 2. Draw active highlight (simplified for performance)
    final activeHighlight = page.activeHighlight;
    if (activeHighlight != null && activeHighlight.points.isNotEmpty) {
      _drawActiveHighlight(canvas, activeHighlight);
    }

    // 3. Draw active stroke (with path caching)
    final activeStroke = page.activeStroke;
    if (activeStroke != null && activeStroke.points.isNotEmpty) {
      _drawActiveStroke(canvas, activeStroke);
    }
  }

  /// ⚡ OPTIMIZED: Active stroke with path caching
  void _drawActiveStroke(Canvas canvas, Stroke stroke) {
    final currentId = stroke.id;
    final currentPointCount = stroke.points.length;

    // Only rebuild path if points actually changed
    if (_cachedActiveId != currentId ||
        _cachedActivePathPointCount != currentPointCount) {
      // Use simple path for very short strokes (faster)
      if (stroke.points.length < 10) {
        _cachedActivePath = _buildSimplePath(stroke.points);
      } else {
        _cachedActivePath = _buildSmoothPath(stroke.points);
      }
      _cachedActivePathPointCount = currentPointCount;
      _cachedActiveId = currentId;
    }

    if (_cachedActivePath == null) return;

    final paint = Paint()
      ..color = Color(stroke.color).withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawPath(_cachedActivePath!, paint);
  }

  /// ⚡ OPTIMIZED: Active highlight WITHOUT blend mode (much faster)
  void _drawActiveHighlight(Canvas canvas, Highlight highlight) {
    if (highlight.points.isEmpty) return;

    // NO BlendMode during active drawing - it's expensive on GPU!
    // Blend mode is only applied in the final cached version
    final paint = Paint()
      ..color = Color(highlight.color).withValues(alpha: highlight.opacity)
      ..strokeWidth = highlight.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Use simple path for short strokes, smooth for longer ones
    final path = highlight.points.length < 10
        ? _buildSimplePath(highlight.points)
        : _buildSmoothPath(highlight.points);

    canvas.drawPath(path, paint);
  }

  // Regular stroke drawing (for non-cached fallback)
  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = Color(stroke.color).withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = _buildSmoothPath(stroke.points);
    canvas.drawPath(path, paint);
  }

  // Regular highlight drawing (with blend mode for cache)
  void _drawHighlight(Canvas canvas, Highlight highlight) {
    if (highlight.points.isEmpty) return;

    final paint = Paint()
      ..color = Color(highlight.color).withValues(alpha: highlight.opacity)
      ..strokeWidth = highlight.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.multiply
      ..isAntiAlias = true;

    final path = _buildSmoothPath(highlight.points);
    canvas.drawPath(path, paint);
  }

  /// ⚡ FAST: Simple straight lines (no bezier math)
  Path _buildSimplePath(List points) {
    final path = Path();
    if (points.isEmpty) return path;

    final first = points.first;
    path.moveTo(first.x, first.y);

    for (int i = 1; i < points.length; i++) {
      final p = points[i];
      path.lineTo(p.x, p.y);
    }

    return path;
  }

  /// Smooth bezier path (same as before)
  Path _buildSmoothPath(List points) {
    final path = Path();

    if (points.isEmpty) return path;

    final first = points.first;
    path.moveTo(first.x, first.y);

    if (points.length == 1) {
      path.lineTo(first.x + 0.01, first.y + 0.01);
      return path;
    }

    if (points.length == 2) {
      final last = points.last;
      path.lineTo(last.x, last.y);
      return path;
    }

    // Quadratic bezier for smooth curves
    for (int i = 1; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.x + p1.x) / 2;
      final midY = (p0.y + p1.y) / 2;
      path.quadraticBezierTo(p0.x, p0.y, midX, midY);
    }

    final last = points.last;
    path.lineTo(last.x, last.y);

    return path;
  }

  @override
  bool shouldRepaint(covariant OptimizedStrokePainter oldDelegate) {
    // Only repaint if page changed
    return oldDelegate.page != page;
  }
}
