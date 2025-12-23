import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

// Use case: tüm belgeleri getirir.
class GetDocumentsUseCase {
  final DocumentRepository _repository;

  const GetDocumentsUseCase(this._repository);

  /// Fetches all documents from the repository.
  Future<List<Document>> call() {
    return _repository.getAllDocuments();
  }
}
