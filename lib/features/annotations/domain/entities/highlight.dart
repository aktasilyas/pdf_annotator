/// Highlight Entity
///
/// Fosforlu kalem ile yapılan işaretlemeyi temsil eder.
/// Stroke'a benzer ama yarı saydam ve farklı blend mode kullanır.
///
/// Kullanım:
/// - Highlighter tool ile çizim
/// - Yarı saydam, multiply blend mode ile render edilir
/// - Genellikle daha kalın çizgi genişliği
library;

import 'package:equatable/equatable.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';

class Highlight extends Equatable {
  /// Unique identifier (UUID)
  final String id;

  /// Bu highlight'ın ait olduğu doküman ID'si
  final String documentId;

  /// Sayfa numarası (0-indexed)
  final int pageNumber;

  /// Annotation tipi (highlight için sabit)
  final AnnotationType type;

  /// İşaretleme rengi (ARGB integer değeri)
  /// Varsayılan: Sarı
  final int color;

  /// Çizgi kalınlığı (piksel)
  /// Highlight için genellikle 15-25px arası
  final double strokeWidth;

  /// Opaklık değeri (0.0 - 1.0)
  /// Highlight için genellikle 0.3-0.5 arası
  final double opacity;

  /// Çizgiyi oluşturan noktalar
  final List<Point> points;

  /// Oluşturulma zamanı
  final DateTime createdAt;

  /// Son güncellenme zamanı
  final DateTime updatedAt;

  /// Soft delete flag (sync için)
  final bool isDeleted;

  /// Katman sırası
  final int zIndex;

  const Highlight({
    required this.id,
    required this.documentId,
    required this.pageNumber,
    this.type = AnnotationType.highlight,
    required this.color,
    this.strokeWidth = 20.0,
    this.opacity = 0.4,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.zIndex = 0,
  });

  /// Yeni değerlerle Highlight kopyası oluşturur
  Highlight copyWith({
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
    return Highlight(
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

  /// Highlight'a yeni point ekler (immutable)
  Highlight addPoint(Point point) {
    return copyWith(points: [...points, point], updatedAt: DateTime.now());
  }

  /// Highlight boş mu kontrol eder
  bool get isEmpty => points.isEmpty;

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
