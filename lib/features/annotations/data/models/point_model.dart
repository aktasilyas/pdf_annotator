/// Point Model
///
/// Point entity'sinin data layer karşılığı.
/// JSON/Map serialization işlemlerini yönetir.
/// Database ve API iletişiminde kullanılır.
library;

import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';

class PointModel {
  /// PDF koordinat sisteminde X pozisyonu
  final double x;

  /// PDF koordinat sisteminde Y pozisyonu
  final double y;

  /// Stylus basınç değeri
  final double pressure;

  /// Oluşturulma zamanı (ms)
  final int? timestamp;

  const PointModel({
    required this.x,
    required this.y,
    this.pressure = 1.0,
    this.timestamp,
  });

  /// Map'ten PointModel oluşturur (DB'den okurken)
  factory PointModel.fromMap(Map<String, dynamic> map) {
    return PointModel(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      pressure: (map['pressure'] as num?)?.toDouble() ?? 1.0,
      timestamp: map['timestamp'] as int?,
    );
  }

  /// PointModel'i Map'e çevirir (DB'ye yazarken)
  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y, 'pressure': pressure, 'timestamp': timestamp};
  }

  /// Entity'den Model oluşturur
  factory PointModel.fromEntity(Point entity) {
    return PointModel(
      x: entity.x,
      y: entity.y,
      pressure: entity.pressure,
      timestamp: entity.timestamp,
    );
  }

  /// Model'i Entity'ye çevirir
  Point toEntity() {
    return Point(x: x, y: y, pressure: pressure, timestamp: timestamp);
  }
}
