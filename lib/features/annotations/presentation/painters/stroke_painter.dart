/// Stroke Painter
///
/// Bitmap cache + aktif çizimi render eder.
/// Listenable pattern ile efficient repaint.
library;

import 'package:flutter/material.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';

class StrokePainter extends CustomPainter {
  final DrawingPage page;

  StrokePainter({required this.page}) : super(repaint: page);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cached bitmap (tamamlanmış çizimler)
    if (page.cachedBitmap != null) {
      canvas.drawImage(
        page.cachedBitmap!,
        Offset.zero,
        Paint()..filterQuality = FilterQuality.low,
      );
    } else if (page.needsCacheRebuild) {
      // Cache yoksa strokes'ları direkt çiz (ilk yükleme)
      for (final highlight in page.highlights) {
        _drawHighlight(canvas, highlight);
      }
      for (final stroke in page.strokes) {
        _drawStroke(canvas, stroke);
      }
    }

    // 2. Aktif highlight (çiziliyor)
    if (page.activeHighlight != null &&
        page.activeHighlight!.points.isNotEmpty) {
      _drawHighlight(canvas, page.activeHighlight!);
    }

    // 3. Aktif stroke (çiziliyor)
    if (page.activeStroke != null && page.activeStroke!.points.isNotEmpty) {
      _drawStroke(canvas, page.activeStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final paint = Paint()
      ..color = Color(stroke.color).withOpacity(stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = _buildPath(stroke.points);
    canvas.drawPath(path, paint);
  }

  void _drawHighlight(Canvas canvas, Highlight highlight) {
    final paint = Paint()
      ..color = Color(highlight.color).withOpacity(highlight.opacity)
      ..strokeWidth = highlight.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.multiply
      ..isAntiAlias = true;

    final path = _buildPath(highlight.points);
    canvas.drawPath(path, paint);
  }

  Path _buildPath(List points) {
    final path = Path();

    if (points.isEmpty) return path;

    final first = points.first;
    path.moveTo(first.x, first.y);

    if (points.length == 1) {
      path.lineTo(first.x + 0.1, first.y + 0.1);
      return path;
    }

    if (points.length == 2) {
      final last = points.last;
      path.lineTo(last.x, last.y);
      return path;
    }

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
    // Sayfa değiştiyse repaint
    return oldDelegate.page != page;
  }
}
