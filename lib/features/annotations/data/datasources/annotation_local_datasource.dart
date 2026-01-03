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
import 'package:pdf_annotator/core/errors/exceptions.dart';
import 'package:pdf_annotator/core/constants/app_constants.dart';

class AnnotationLocalDatasource {
  /// Belirli bir sayfadaki annotation'ları getirir
  ///
  /// [documentId]: Doküman ID
  /// [pageNumber]: Sayfa numarası
  /// [type]: Opsiyonel tip filtresi
  /// Throws: [AppDatabaseException] database işlemi başarısızsa
  Future<List<AnnotationModel>> getAnnotationsByPage(
    String documentId,
    int pageNumber, {
    AnnotationType? type,
  }) async {
    try {
      final db = DatabaseService.instance;

      String whereClause =
          'document_id = ? AND page_number = ? AND is_deleted = 0';
      List<dynamic> whereArgs = [documentId, pageNumber];

      if (type != null) {
        whereClause += ' AND type = ?';
        whereArgs.add(type.toDbString());
      }

      final result = await db.query(
        DatabaseConstants.annotationsTable,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'z_index ASC',
      );

      return result.map((map) => AnnotationModel.fromMap(map)).toList();
    } catch (e, st) {
      if (e is ValidationException) {
        // JSON parsing hatası - rethrow
        rethrow;
      }
      throw AppDatabaseException(
        message: 'Annotation\'lar yüklenemedi',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// ID ile tek annotation getirir
  ///
  /// Throws: [AppDatabaseException] database işlemi başarısızsa
  Future<AnnotationModel?> getAnnotationById(String id) async {
    try {
      final db = DatabaseService.instance;

      final result = await db.query(
        DatabaseConstants.annotationsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;
      return AnnotationModel.fromMap(result.first);
    } catch (e, st) {
      if (e is ValidationException) {
        rethrow;
      }
      throw AppDatabaseException(
        message: 'Annotation bulunamadı',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Yeni annotation ekler
  ///
  /// Throws: [AppDatabaseException] insert başarısızsa
  Future<void> insertAnnotation(AnnotationModel annotation) async {
    try {
      final db = DatabaseService.instance;
      await db.insert(
        DatabaseConstants.annotationsTable,
        annotation.toMap(),
      );
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Annotation eklenemedi',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Annotation günceller
  ///
  /// Throws: [AppDatabaseException] update başarısızsa
  Future<void> updateAnnotation(AnnotationModel annotation) async {
    try {
      final db = DatabaseService.instance;
      await db.update(
        DatabaseConstants.annotationsTable,
        annotation.toMap(),
        where: 'id = ?',
        whereArgs: [annotation.id],
      );
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Annotation güncellenemedi',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Annotation siler (hard delete)
  ///
  /// Throws: [AppDatabaseException] delete başarısızsa
  Future<void> deleteAnnotation(String id) async {
    try {
      final db = DatabaseService.instance;
      await db.delete(
        DatabaseConstants.annotationsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Annotation silinemedi',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Sayfadaki tüm annotation'ları siler
  ///
  /// Throws: [AppDatabaseException] delete başarısızsa
  Future<void> deleteAnnotationsByPage(
    String documentId,
    int pageNumber,
  ) async {
    try {
      final db = DatabaseService.instance;
      await db.delete(
        DatabaseConstants.annotationsTable,
        where: 'document_id = ? AND page_number = ?',
        whereArgs: [documentId, pageNumber],
      );
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Sayfa annotation\'ları silinemedi',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Dokümandaki tüm annotation'ları siler
  ///
  /// Throws: [AppDatabaseException] delete başarısızsa
  Future<void> deleteAnnotationsByDocument(String documentId) async {
    try {
      final db = DatabaseService.instance;
      await db.delete(
        DatabaseConstants.annotationsTable,
        where: 'document_id = ?',
        whereArgs: [documentId],
      );
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Doküman annotation\'ları silinemedi',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Sayfadaki maksimum z-index değerini getirir
  ///
  /// Throws: [AppDatabaseException] query başarısızsa
  Future<int> getMaxZIndex(String documentId, int pageNumber) async {
    try {
      final db = DatabaseService.instance;

      final result = await db.rawQuery(
        'SELECT MAX(z_index) as max_z FROM ${DatabaseConstants.annotationsTable} WHERE document_id = ? AND page_number = ?',
        [documentId, pageNumber],
      );

      final maxZ = result.first['max_z'];
      return (maxZ as int?) ?? 0;
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Z-index sorgulanamadı',
        originalError: e,
        stackTrace: st,
      );
    }
  }
}
