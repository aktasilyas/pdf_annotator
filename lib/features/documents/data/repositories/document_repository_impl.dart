/// Document Repository Implementation
///
/// DocumentRepository interface'inin concrete implementasyonu.
/// Error handling ve logging eklenmiş versiyon.
///
/// Tüm metodlar:
/// - Exception'ları yakalar
/// - Log'a yazar
/// - Result<T> döner
library;

import 'package:pdf_annotator/core/errors/failures.dart';
import 'package:pdf_annotator/core/utils/logger.dart';
import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/features/documents/data/datasources/document_local_datasource.dart';
import 'package:pdf_annotator/features/documents/data/models/document_model.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDatasource _datasource;

  DocumentRepositoryImpl(this._datasource);

  @override
  Future<Result<List<Document>>> getAllDocuments() async {
    try {
      logger.debug('Fetching all documents');

      final models = await _datasource.getAllDocuments();
      final documents = models.map((model) => model.toEntity()).toList();

      logger.info('Fetched ${documents.length} documents');
      return Success(documents);
    } catch (e, st) {
      logger.error('Failed to fetch documents', error: e, stackTrace: st);
      return Error(DatabaseFailure.general(e.toString()));
    }
  }

  @override
  Future<Result<Document?>> getDocumentById(String id) async {
    try {
      logger.debug('Fetching document: $id');

      final model = await _datasource.getDocumentById(id);
      final document = model?.toEntity();

      if (document != null) {
        logger.debug('Found document: ${document.title}');
      } else {
        logger.debug('Document not found: $id');
      }

      return Success(document);
    } catch (e, st) {
      logger.error('Failed to fetch document: $id', error: e, stackTrace: st);
      return Error(DatabaseFailure.notFound('Doküman'));
    }
  }

  @override
  Future<Result<void>> insertDocument(Document document) async {
    try {
      logger.debug('Inserting document: ${document.title}');

      final model = DocumentModel.fromEntity(document);
      await _datasource.insertDocument(model);

      logger.info(
        'Document inserted: ${document.title}',
        details: {
          'id': document.id,
          'pageCount': document.pageCount,
          'fileSize': document.fileSize,
        },
      );

      return const Success(null);
    } catch (e, st) {
      logger.error(
        'Failed to insert document: ${document.title}',
        error: e,
        stackTrace: st,
      );
      return Error(DatabaseFailure.insertFailed('Doküman'));
    }
  }

  @override
  Future<Result<void>> updateDocument(Document document) async {
    try {
      logger.debug('Updating document: ${document.id}');

      final model = DocumentModel.fromEntity(document);
      await _datasource.updateDocument(model);

      logger.debug('Document updated: ${document.title}');
      return const Success(null);
    } catch (e, st) {
      logger.error(
        'Failed to update document: ${document.id}',
        error: e,
        stackTrace: st,
      );
      return Error(DatabaseFailure.updateFailed('Doküman'));
    }
  }

  @override
  Future<Result<void>> deleteDocument(String id) async {
    try {
      logger.debug('Deleting document: $id');

      await _datasource.deleteDocument(id);

      logger.info('Document deleted: $id');
      return const Success(null);
    } catch (e, st) {
      logger.error('Failed to delete document: $id', error: e, stackTrace: st);
      return Error(DatabaseFailure.deleteFailed('Doküman'));
    }
  }
}
