/// Annotation Local Datasource
///
/// SQLite veritabanı ile annotation CRUD işlemlerini gerçekleştirir.
/// Repository implementation tarafından kullanılır.
///
/// Tablo: annotations
/// - Tüm annotation tipleri tek tabloda saklanır
/// - Points JSON string olarak saklanır
library;

import 'package:pdf_annotator/database/database_service.dart';
import 'package:pdf_annotator/features/annotations/data/models/annotation_model.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';

class AnnotationLocalDatasource {
  /// Belirli bir sayfadaki annotation'ları getirir
  ///
  /// [documentId]: Doküman ID
  /// [pageNumber]: Sayfa numarası
  /// [type]: Opsiyonel tip filtresi
  Future<List<AnnotationModel>> getAnnotationsByPage(
    String documentId,
    int pageNumber, {
    AnnotationType? type,
  }) async {
    final db = DatabaseService.instance;

    String whereClause =
        'document_id = ? AND page_number = ? AND is_deleted = 0';
    List<dynamic> whereArgs = [documentId, pageNumber];

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.toDbString());
    }

    final result = await db.query(
      'annotations',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'z_index ASC',
    );

    return result.map((map) => AnnotationModel.fromMap(map)).toList();
  }

  /// ID ile tek annotation getirir
  Future<AnnotationModel?> getAnnotationById(String id) async {
    final db = DatabaseService.instance;

    final result = await db.query(
      'annotations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return AnnotationModel.fromMap(result.first);
  }

  /// Yeni annotation ekler
  Future<void> insertAnnotation(AnnotationModel annotation) async {
    final db = DatabaseService.instance;
    await db.insert('annotations', annotation.toMap());
  }

  /// Annotation günceller
  Future<void> updateAnnotation(AnnotationModel annotation) async {
    final db = DatabaseService.instance;
    await db.update(
      'annotations',
      annotation.toMap(),
      where: 'id = ?',
      whereArgs: [annotation.id],
    );
  }

  /// Annotation siler (hard delete)
  Future<void> deleteAnnotation(String id) async {
    final db = DatabaseService.instance;
    await db.delete('annotations', where: 'id = ?', whereArgs: [id]);
  }

  /// Sayfadaki tüm annotation'ları siler
  Future<void> deleteAnnotationsByPage(
    String documentId,
    int pageNumber,
  ) async {
    final db = DatabaseService.instance;
    await db.delete(
      'annotations',
      where: 'document_id = ? AND page_number = ?',
      whereArgs: [documentId, pageNumber],
    );
  }

  /// Dokümandaki tüm annotation'ları siler
  Future<void> deleteAnnotationsByDocument(String documentId) async {
    final db = DatabaseService.instance;
    await db.delete(
      'annotations',
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
  }

  /// Sayfadaki maksimum z-index değerini getirir
  Future<int> getMaxZIndex(String documentId, int pageNumber) async {
    final db = DatabaseService.instance;

    final result = await db.rawQuery(
      'SELECT MAX(z_index) as max_z FROM annotations WHERE document_id = ? AND page_number = ?',
      [documentId, pageNumber],
    );

    final maxZ = result.first['max_z'];
    return (maxZ as int?) ?? 0;
  }
}
