/// Stroke Smoother
///
/// Catmull-Rom spline ile çizgileri yumuşatır.
/// Daha doğal kalem darbesi sağlar.
library;

import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

class StrokeSmoother {
  /// Tension (0.0 - 1.0). Düşük = daha yumuşak
  final double tension;

  /// Her segment için ara nokta sayısı
  final int segmentsPerCurve;

  const StrokeSmoother({this.tension = 0.5, this.segmentsPerCurve = 3});

  /// Stroke'u yumuşat
  Stroke smoothStroke(Stroke stroke) {
    if (stroke.points.length < 4) return stroke;

    final smoothedPoints = _catmullRomSmooth(stroke.points);
    return stroke.copyWith(points: smoothedPoints);
  }

  /// Highlight'ı yumuşat
  Highlight smoothHighlight(Highlight highlight) {
    if (highlight.points.length < 4) return highlight;

    final smoothedPoints = _catmullRomSmooth(highlight.points);
    return highlight.copyWith(points: smoothedPoints);
  }

  /// Catmull-Rom spline uygula
  List<Point> _catmullRomSmooth(List<Point> points) {
    if (points.length < 4) return points;

    final result = <Point>[];

    // İlk noktayı ekle
    result.add(points.first);

    // Edge handling için duplicate
    final extended = [points.first, ...points, points.last];

    // Her segment için interpolate
    for (int i = 1; i < extended.length - 2; i++) {
      final p0 = extended[i - 1];
      final p1 = extended[i];
      final p2 = extended[i + 1];
      final p3 = extended[i + 2];

      // p1 ve p2 arasını interpolate et
      for (int j = 1; j <= segmentsPerCurve; j++) {
        final t = j / segmentsPerCurve;
        final interpolated = _interpolate(p0, p1, p2, p3, t);
        result.add(interpolated);
      }
    }

    return result;
  }

  /// Catmull-Rom interpolation
  Point _interpolate(Point p0, Point p1, Point p2, Point p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;

    // Catmull-Rom matrix
    final x =
        0.5 *
        ((2 * p1.x) +
            (-p0.x + p2.x) * t +
            (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
            (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3);

    final y =
        0.5 *
        ((2 * p1.y) +
            (-p0.y + p2.y) * t +
            (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
            (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3);

    // Pressure linear interpolate
    final pressure = p1.pressure + (p2.pressure - p1.pressure) * t;

    // Timestamp linear interpolate
    final t1 = p1.timestamp ?? 0;
    final t2Time = p2.timestamp ?? 0;
    final timestamp = (t1 + (t2Time - t1) * t).round();

    return Point(x: x, y: y, pressure: pressure, timestamp: timestamp);
  }
}
