/// Point Entity
///
/// Çizim sırasında oluşan her bir noktayı temsil eder.
/// PDF koordinat sisteminde saklanır (ekran koordinatı değil).
///
/// Özellikler:
/// - [x], [y]: PDF sayfası üzerindeki koordinatlar
/// - [pressure]: Apple Pencil/Stylus basınç değeri (0.0 - 1.0)
/// - [timestamp]: Noktanın oluşturulma zamanı (ms)
library;

import 'package:equatable/equatable.dart';

class Point extends Equatable {
  /// PDF koordinat sisteminde X pozisyonu
  final double x;

  /// PDF koordinat sisteminde Y pozisyonu
  final double y;

  /// Stylus/Pencil basınç değeri (0.0 - 1.0 arası)
  /// Basınç desteklenmiyorsa varsayılan 1.0
  final double pressure;

  /// Noktanın oluşturulma zamanı (milliseconds since epoch)
  /// Çizim hızı analizi için kullanılabilir
  final int? timestamp;

  const Point({
    required this.x,
    required this.y,
    this.pressure = 1.0,
    this.timestamp,
  });

  /// Yeni değerlerle Point kopyası oluşturur
  Point copyWith({double? x, double? y, double? pressure, int? timestamp}) {
    return Point(
      x: x ?? this.x,
      y: y ?? this.y,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [x, y, pressure, timestamp];

  @override
  String toString() => 'Point(x: $x, y: $y, pressure: $pressure)';
}
