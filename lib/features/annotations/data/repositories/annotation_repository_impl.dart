/// Annotation Repository Implementation
///
/// AnnotationRepository interface'inin concrete implementasyonu.
/// Local datasource kullanarak CRUD işlemlerini gerçekleştirir.
///
/// Bu sınıf:
/// - Model <-> Entity dönüşümlerini yönetir
/// - Datasource'u abstract repository'ye bağlar
library;

import 'package:pdf_annotator/features/annotations/data/datasources/annotation_local_datasource.dart';
import 'package:pdf_annotator/features/annotations/data/models/annotation_model.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/repositories/annotation_repository.dart';

class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalDatasource _datasource;

  AnnotationRepositoryImpl(this._datasource);

  @override
  Future<List<Stroke>> getStrokesByPage(
    String documentId,
    int pageNumber,
  ) async {
    final models = await _datasource.getAnnotationsByPage(
      documentId,
      pageNumber,
      type: AnnotationType.stroke,
    );
    return models.map((model) => model.toStroke()).toList();
  }

  @override
  Future<List<Highlight>> getHighlightsByPage(
    String documentId,
    int pageNumber,
  ) async {
    final models = await _datasource.getAnnotationsByPage(
      documentId,
      pageNumber,
      type: AnnotationType.highlight,
    );
    return models.map((model) => model.toHighlight()).toList();
  }

  @override
  Future<void> insertStroke(Stroke stroke) async {
    final model = AnnotationModel.fromStroke(stroke);
    await _datasource.insertAnnotation(model);
  }

  @override
  Future<void> insertHighlight(Highlight highlight) async {
    final model = AnnotationModel.fromHighlight(highlight);
    await _datasource.insertAnnotation(model);
  }

  @override
  Future<void> updateStroke(Stroke stroke) async {
    final model = AnnotationModel.fromStroke(stroke);
    await _datasource.updateAnnotation(model);
  }

  @override
  Future<void> updateHighlight(Highlight highlight) async {
    final model = AnnotationModel.fromHighlight(highlight);
    await _datasource.updateAnnotation(model);
  }

  @override
  Future<void> deleteAnnotation(String id) async {
    await _datasource.deleteAnnotation(id);
  }

  @override
  Future<void> deleteAnnotationsByPage(
    String documentId,
    int pageNumber,
  ) async {
    await _datasource.deleteAnnotationsByPage(documentId, pageNumber);
  }

  @override
  Future<void> deleteAnnotationsByDocument(String documentId) async {
    await _datasource.deleteAnnotationsByDocument(documentId);
  }

  @override
  Future<int> getMaxZIndex(String documentId, int pageNumber) async {
    return await _datasource.getMaxZIndex(documentId, pageNumber);
  }
}
