/// Get Documents UseCase
///
/// Tüm dokümanları getirme işlemini yönetir.
/// Repository'den verileri alır ve Result döner.
library;

import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

class GetDocumentsUseCase {
  final DocumentRepository _repository;

  const GetDocumentsUseCase(this._repository);

  /// Tüm dokümanları getirir
  ///
  /// Returns: Result<List<Document>>
  /// - Success: Doküman listesi
  /// - Error: Hata bilgisi
  Future<Result<List<Document>>> call() {
    return _repository.getAllDocuments();
  }
}
