/// Annotation Base Entity
///
/// Tüm annotation tiplerini kapsayan abstract base class.
/// Ortak özellikleri tanımlar ve polimorfik kullanım sağlar.
///
/// Alt sınıflar:
/// - [Stroke]: Kalem çizimi
/// - [Highlight]: Fosforlu kalem
/// - TextNote: Metin notu (Post-MVP)
library;

import 'package:equatable/equatable.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';

abstract class Annotation extends Equatable {
  /// Unique identifier (UUID)
  String get id;

  /// Annotation'ın ait olduğu doküman ID'si
  String get documentId;

  /// Sayfa numarası (0-indexed)
  int get pageNumber;

  /// Annotation tipi
  AnnotationType get type;

  /// Renk (ARGB integer)
  int get color;

  /// Çizgi kalınlığı
  double get strokeWidth;

  /// Opaklık (0.0 - 1.0)
  double get opacity;

  /// Noktalar listesi
  List<Point> get points;

  /// Oluşturulma zamanı
  DateTime get createdAt;

  /// Güncellenme zamanı
  DateTime get updatedAt;

  /// Soft delete flag
  bool get isDeleted;

  /// Katman sırası
  int get zIndex;

  const Annotation();
}
