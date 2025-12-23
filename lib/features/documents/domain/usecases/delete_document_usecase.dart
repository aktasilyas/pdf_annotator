import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';
import 'package:pdf_annotator/features/documents/domain/services/file_storage_repository.dart';

// Use case: hem dosyayı hem veritabanı kaydını siler.
class DeleteDocumentUseCase {
  final DocumentRepository _repository;
  final FileStorageRepository _fileStorage;

  const DeleteDocumentUseCase(this._repository, this._fileStorage);

  /// Deletes the physical file and its DB record.
  Future<void> call(Document document) async {
    await _fileStorage.deleteFile(document.filePath);
    await _repository.deleteDocument(document.id);
  }
}
