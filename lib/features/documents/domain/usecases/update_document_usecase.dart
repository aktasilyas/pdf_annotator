import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

// Use case: mevcut belgeyi günceller.
class UpdateDocumentUseCase {
  final DocumentRepository _repository;

  const UpdateDocumentUseCase(this._repository);

  /// Persists the updated document fields.
  Future<void> call(Document document) {
    return _repository.updateDocument(document);
  }
}
