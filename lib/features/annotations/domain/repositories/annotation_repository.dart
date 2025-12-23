/// Annotation Repository Interface
///
/// Annotation CRUD işlemleri için abstract sözleşme.
/// Domain katmanında tanımlanır, Data katmanında implement edilir.
///
/// Bu interface sayesinde:
/// - Domain katmanı data katmanından bağımsız kalır
/// - Test için mock repository kullanılabilir
/// - Farklı data kaynakları (local, remote) kolayca değiştirilebilir
library;

import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

abstract class AnnotationRepository {
  /// Belirli bir sayfadaki tüm stroke'ları getirir
  Future<List<Stroke>> getStrokesByPage(String documentId, int pageNumber);

  /// Belirli bir sayfadaki tüm highlight'ları getirir
  Future<List<Highlight>> getHighlightsByPage(
    String documentId,
    int pageNumber,
  );

  /// Yeni stroke ekler
  Future<void> insertStroke(Stroke stroke);

  /// Yeni highlight ekler
  Future<void> insertHighlight(Highlight highlight);

  /// Stroke günceller
  Future<void> updateStroke(Stroke stroke);

  /// Highlight günceller
  Future<void> updateHighlight(Highlight highlight);

  /// Annotation siler (ID ile)
  Future<void> deleteAnnotation(String id);

  /// Sayfadaki tüm annotation'ları siler
  Future<void> deleteAnnotationsByPage(String documentId, int pageNumber);

  /// Dokümandaki tüm annotation'ları siler
  Future<void> deleteAnnotationsByDocument(String documentId);

  /// Son Z-index değerini getirir (yeni annotation için)
  Future<int> getMaxZIndex(String documentId, int pageNumber);
}
