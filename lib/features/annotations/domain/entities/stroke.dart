/// Stroke Entity
///
/// Kalem ile yapılan serbest çizimi temsil eder.
/// Birden fazla Point içerir ve stil bilgilerini saklar.
///
/// Kullanım:
/// - Pen tool ile çizim
/// - Opak, normal blend mode ile render edilir
library;

import 'package:equatable/equatable.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';

class Stroke extends Equatable {
  /// Unique identifier (UUID)
  final String id;

  /// Bu stroke'un ait olduğu doküman ID'si
  final String documentId;

  /// Sayfa numarası (0-indexed)
  final int pageNumber;

  /// Annotation tipi (stroke için sabit)
  final AnnotationType type;

  /// Çizgi rengi (ARGB integer değeri)
  final int color;

  /// Çizgi kalınlığı (piksel)
  final double strokeWidth;

  /// Opaklık değeri (0.0 - 1.0)
  final double opacity;

  /// Çizgiyi oluşturan noktalar
  final List<Point> points;

  /// Oluşturulma zamanı
  final DateTime createdAt;

  /// Son güncellenme zamanı
  final DateTime updatedAt;

  /// Soft delete flag (sync için)
  final bool isDeleted;

  /// Katman sırası (üst üste çizimler için)
  final int zIndex;

  const Stroke({
    required this.id,
    required this.documentId,
    required this.pageNumber,
    this.type = AnnotationType.stroke,
    required this.color,
    required this.strokeWidth,
    this.opacity = 1.0,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.zIndex = 0,
  });

  /// Yeni değerlerle Stroke kopyası oluşturur
  Stroke copyWith({
    String? id,
    String? documentId,
    int? pageNumber,
    AnnotationType? type,
    int? color,
    double? strokeWidth,
    double? opacity,
    List<Point>? points,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? zIndex,
  }) {
    return Stroke(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      pageNumber: pageNumber ?? this.pageNumber,
      type: type ?? this.type,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  /// Stroke'a yeni point ekler (immutable)
  Stroke addPoint(Point point) {
    return copyWith(points: [...points, point], updatedAt: DateTime.now());
  }

  /// Stroke boş mu kontrol eder
  bool get isEmpty => points.isEmpty;

  /// Stroke'un bounding box'ını hesaplar
  /// Returns: (minX, minY, maxX, maxY)
  (double, double, double, double)? get boundingBox {
    if (points.isEmpty) return null;

    double minX = points.first.x;
    double minY = points.first.y;
    double maxX = points.first.x;
    double maxY = points.first.y;

    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }

    return (minX, minY, maxX, maxY);
  }

  @override
  List<Object?> get props => [
    id,
    documentId,
    pageNumber,
    type,
    color,
    strokeWidth,
    opacity,
    points,
    createdAt,
    updatedAt,
    isDeleted,
    zIndex,
  ];
}
