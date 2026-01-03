/// Bitmap Cache Manager
///
/// High DPI bitmap cache for crisp rendering.
/// Uses device pixel ratio for sharp strokes at any zoom level.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';

class BitmapCacheManager {
  const BitmapCacheManager();

  /// Rebuild complete cache at high resolution
  Future<ui.Image?> rebuildCache(DrawingPage page) async {
    if (page.strokes.isEmpty && page.highlights.isEmpty) {
      return null;
    }

    final pixelRatio = page.pixelRatio;
    final width = (page.pageSize.width * pixelRatio).ceil();
    final height = (page.pageSize.height * pixelRatio).ceil();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Scale up for high DPI
    canvas.scale(pixelRatio);

    // Draw highlights (below strokes)
    for (final highlight in page.highlights) {
      _drawHighlight(canvas, highlight);
    }

    // Draw strokes
    for (final stroke in page.strokes) {
      _drawStroke(canvas, stroke);
    }

    final picture = recorder.endRecording();

    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
  }

  /// Append stroke to existing cache
  Future<ui.Image?> appendStroke(
    DrawingPage page,
    ui.Image? existingCache,
    Stroke newStroke,
  ) async {
    final pixelRatio = page.pixelRatio;
    final width = (page.pageSize.width * pixelRatio).ceil();
    final height = (page.pageSize.height * pixelRatio).ceil();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw existing cache at full resolution
    if (existingCache != null) {
      canvas.drawImage(existingCache, Offset.zero, Paint());
    }

    // Scale for new stroke
    canvas.scale(pixelRatio);

    // Draw new stroke
    _drawStroke(canvas, newStroke);

    final picture = recorder.endRecording();

    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
  }

  /// Append highlight to existing cache
  /// Note: Highlights use blend mode, so we need to rebuild cache
  /// But we only do full rebuild if there are multiple highlights
  Future<ui.Image?> appendHighlight(
    DrawingPage page,
    ui.Image? existingCache,
    Highlight newHighlight,
  ) async {
    final pixelRatio = page.pixelRatio;
    final width = (page.pageSize.width * pixelRatio).ceil();
    final height = (page.pageSize.height * pixelRatio).ceil();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // If no existing cache, rebuild from scratch
    if (existingCache == null || page.highlights.length <= 1) {
      // Scale for drawing
      canvas.scale(pixelRatio);

      // Draw all highlights
      for (final highlight in page.highlights) {
        _drawHighlight(canvas, highlight);
      }

      // Draw all strokes on top
      for (final stroke in page.strokes) {
        _drawStroke(canvas, stroke);
      }
    } else {
      // Draw existing cache first
      canvas.drawImage(existingCache, Offset.zero, Paint());

      // Scale for new highlight
      canvas.scale(pixelRatio);

      // Only draw new highlight with blend mode
      _drawHighlight(canvas, newHighlight);
    }

    final picture = recorder.endRecording();

    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
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

  /// Build smooth path using quadratic bezier curves
  Path _buildSmoothPath(List points) {
    final path = Path();

    if (points.isEmpty) return path;

    final first = points.first;
    path.moveTo(first.x, first.y);

    if (points.length == 1) {
      // Single point - draw tiny line for visibility
      path.lineTo(first.x + 0.01, first.y + 0.01);
      return path;
    }

    if (points.length == 2) {
      final last = points.last;
      path.lineTo(last.x, last.y);
      return path;
    }

    // Use quadratic bezier for smooth curves
    for (int i = 1; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.x + p1.x) / 2;
      final midY = (p0.y + p1.y) / 2;
      path.quadraticBezierTo(p0.x, p0.y, midX, midY);
    }

    // Connect to last point
    final last = points.last;
    path.lineTo(last.x, last.y);

    return path;
  }
}
