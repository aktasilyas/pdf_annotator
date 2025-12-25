/// Bitmap Cache Manager
///
/// Tamamlanmış çizimleri ui.Image olarak cache'ler.
/// Memory-safe implementasyon.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';

class BitmapCacheManager {
  const BitmapCacheManager();

  /// Tüm çizimlerden bitmap oluştur
  Future<ui.Image?> rebuildCache(DrawingPage page) async {
    if (page.strokes.isEmpty && page.highlights.isEmpty) {
      return null;
    }

    final width = page.pageSize.width.ceil();
    final height = page.pageSize.height.ceil();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Highlight'ları çiz (altta)
    for (final highlight in page.highlights) {
      _drawHighlight(canvas, highlight);
    }

    // Stroke'ları çiz (üstte)
    for (final stroke in page.strokes) {
      _drawStroke(canvas, stroke);
    }

    final picture = recorder.endRecording();

    try {
      final image = await picture.toImage(width, height);
      return image;
    } finally {
      picture.dispose();
    }
  }

  /// Mevcut cache'e yeni stroke ekle
  Future<ui.Image?> appendStroke(
    DrawingPage page,
    ui.Image? existingCache,
    Stroke newStroke,
  ) async {
    final width = page.pageSize.width.ceil();
    final height = page.pageSize.height.ceil();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Mevcut cache'i çiz
    if (existingCache != null) {
      canvas.drawImage(existingCache, Offset.zero, Paint());
    }

    // Yeni stroke'u çiz
    _drawStroke(canvas, newStroke);

    final picture = recorder.endRecording();

    try {
      final image = await picture.toImage(width, height);
      return image;
    } finally {
      picture.dispose();
    }
  }

  /// Mevcut cache'e yeni highlight ekle
  Future<ui.Image?> appendHighlight(
    DrawingPage page,
    ui.Image? existingCache,
    Highlight newHighlight,
  ) async {
    final width = page.pageSize.width.ceil();
    final height = page.pageSize.height.ceil();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Mevcut cache'i çiz
    if (existingCache != null) {
      canvas.drawImage(existingCache, Offset.zero, Paint());
    }

    // Yeni highlight'ı çiz
    _drawHighlight(canvas, newHighlight);

    final picture = recorder.endRecording();

    try {
      final image = await picture.toImage(width, height);
      return image;
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

    final path = _buildPath(stroke.points);
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

    // Quadratic Bezier ile yumuşat
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
}
