/// Stroke Smoother
///
/// Minimal smoothing - orijinal noktaları korur.
/// Sadece çok keskin köşeleri yumuşatır.
library;

import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

class StrokeSmoother {
  /// Smoothing miktarı (0 = yok, 1 = maksimum)
  final double smoothingFactor;

  const StrokeSmoother({
    this.smoothingFactor = 0.2, // Düşük değer = daha az smoothing
  });

  /// Stroke'u yumuşat (minimal)
  Stroke smoothStroke(Stroke stroke) {
    if (stroke.points.length < 4) return stroke;

    // Smoothing faktörü 0 ise direkt döndür
    if (smoothingFactor <= 0) return stroke;

    final smoothedPoints = _smoothPoints(stroke.points);
    return stroke.copyWith(points: smoothedPoints);
  }

  /// Highlight'ı yumuşat (minimal)
  Highlight smoothHighlight(Highlight highlight) {
    if (highlight.points.length < 4) return highlight;

    if (smoothingFactor <= 0) return highlight;

    final smoothedPoints = _smoothPoints(highlight.points);
    return highlight.copyWith(points: smoothedPoints);
  }

  /// Moving average ile hafif smoothing
  List<Point> _smoothPoints(List<Point> points) {
    if (points.length < 3) return points;

    final result = <Point>[];

    // İlk nokta
    result.add(points.first);

    // Ortadaki noktalar - hafif average
    for (int i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final next = points[i + 1];

      // Weighted average: current ağırlıklı
      final weight = 1.0 - smoothingFactor;
      final smoothX = curr.x * weight + (prev.x + next.x) / 2 * smoothingFactor;
      final smoothY = curr.y * weight + (prev.y + next.y) / 2 * smoothingFactor;

      result.add(
        Point(
          x: smoothX,
          y: smoothY,
          pressure: curr.pressure,
          timestamp: curr.timestamp,
        ),
      );
    }

    // Son nokta
    result.add(points.last);

    return result;
  }
}
