/// Document Repository Interface
///
/// Document CRUD işlemleri için abstract sözleşme.
/// Result type ile error handling destekler.
library;

import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';

abstract class DocumentRepository {
  /// Tüm dokümanları getirir
  Future<Result<List<Document>>> getAllDocuments();

  /// ID ile doküman getirir
  Future<Result<Document?>> getDocumentById(String id);

  /// Yeni doküman ekler
  Future<Result<void>> insertDocument(Document document);

  /// Doküman günceller
  Future<Result<void>> updateDocument(Document document);

  /// Doküman siler
  Future<Result<void>> deleteDocument(String id);
}
