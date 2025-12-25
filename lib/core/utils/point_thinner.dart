/// Point Thinner
///
/// Gereksiz noktaları filtreler, performansı artırır.
/// Minimum mesafe ve zaman kontrolü yapar.
library;

import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';

class PointThinner {
  /// Minimum mesafe (page units)
  final double minDistance;

  /// Minimum zaman farkı (ms)
  final int minTimeDelta;

  const PointThinner({this.minDistance = 2.0, this.minTimeDelta = 8});

  /// Yeni nokta eklenebilir mi?
  bool shouldAddPoint(Point? lastPoint, Point newPoint) {
    if (lastPoint == null) return true;

    // Mesafe kontrolü
    final dx = newPoint.x - lastPoint.x;
    final dy = newPoint.y - lastPoint.y;
    final distance = (dx * dx + dy * dy);

    if (distance < minDistance * minDistance) {
      // Zaman kontrolü - yeterince zaman geçtiyse ekle
      final lastTime = lastPoint.timestamp ?? 0;
      final newTime = newPoint.timestamp ?? 0;
      final timeDelta = newTime - lastTime;
      return timeDelta >= minTimeDelta;
    }

    return true;
  }

  /// Nokta listesini filtrele
  List<Point> thinPoints(List<Point> points) {
    if (points.length <= 2) return points;

    final result = <Point>[points.first];

    for (int i = 1; i < points.length - 1; i++) {
      if (shouldAddPoint(result.last, points[i])) {
        result.add(points[i]);
      }
    }

    // Son noktayı her zaman ekle
    result.add(points.last);

    return result;
  }
}
