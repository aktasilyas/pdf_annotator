/// Stroke Painter
///
/// High DPI aware painter that renders:
/// 1. Cached bitmap (scaled down from high res)
/// 2. Active stroke (real-time)
///
/// Uses same path building as cache for visual consistency.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';

class StrokePainter extends CustomPainter {
  final DrawingPage page;

  StrokePainter({required this.page}) : super(repaint: page);

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

      canvas.drawImageRect(
        page.cachedBitmap!,
        src,
        dst,
        Paint()
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true,
      );
    } else if (page.strokes.isNotEmpty || page.highlights.isNotEmpty) {
      // No cache yet, draw directly
      for (final highlight in page.highlights) {
        _drawHighlight(canvas, highlight);
      }
      for (final stroke in page.strokes) {
        _drawStroke(canvas, stroke);
      }
    }

    // 2. Draw active highlight
    final activeHighlight = page.activeHighlight;
    if (activeHighlight != null && activeHighlight.points.isNotEmpty) {
      _drawHighlight(canvas, activeHighlight);
    }

    // 3. Draw active stroke
    final activeStroke = page.activeStroke;
    if (activeStroke != null && activeStroke.points.isNotEmpty) {
      _drawStroke(canvas, activeStroke);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = Color(stroke.color).withOpacity(stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = _buildSmoothPath(stroke.points);
    canvas.drawPath(path, paint);
  }

  void _drawHighlight(Canvas canvas, Highlight highlight) {
    if (highlight.points.isEmpty) return;

    final paint = Paint()
      ..color = Color(highlight.color).withOpacity(highlight.opacity)
      ..strokeWidth = highlight.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.multiply
      ..isAntiAlias = true;

    final path = _buildSmoothPath(highlight.points);
    canvas.drawPath(path, paint);
  }

  /// Same path building as cache manager for consistency
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
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return oldDelegate.page != page;
  }
}
