/// Delete Document UseCase
///
/// Doküman silme işlemini yönetir.
library;

import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

class DeleteDocumentUseCase {
  final DocumentRepository _repository;

  const DeleteDocumentUseCase(this._repository);

  /// Dokümanı siler
  ///
  /// [id]: Silinecek doküman ID'si
  ///
  /// Returns: Result<void>
  /// - Success: İşlem başarılı
  /// - Error: Hata bilgisi
  Future<Result<void>> call(String id) {
    return _repository.deleteDocument(id);
  }
}
