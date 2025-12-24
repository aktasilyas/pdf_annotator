/// Update Document UseCase
///
/// Doküman güncelleme işlemini yönetir.
library;

import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

class UpdateDocumentUseCase {
  final DocumentRepository _repository;

  const UpdateDocumentUseCase(this._repository);

  /// Dokümanı günceller
  ///
  /// [document]: Güncellenecek doküman
  ///
  /// Returns: Result<void>
  /// - Success: İşlem başarılı
  /// - Error: Hata bilgisi
  Future<Result<void>> call(Document document) {
    return _repository.updateDocument(document);
  }
}
