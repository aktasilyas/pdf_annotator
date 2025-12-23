import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';
import 'package:pdf_annotator/features/documents/domain/services/file_storage_repository.dart';
import 'package:uuid/uuid.dart';

// Use case: PDF seçip uygulama dizinine kopyalar ve Document olarak kaydeder.
class ImportDocumentUseCase {
  final DocumentRepository _repository;
  final FileStorageRepository _fileStorage;
  final Uuid _uuid;

  ImportDocumentUseCase(
    this._repository,
    this._fileStorage, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  /// Runs the import flow; returns created document or null if user cancels.
  Future<Document?> call() async {
    final pickedFile = await _fileStorage.pickPdfFile();
    if (pickedFile == null) return null;

    final copiedFile = await _fileStorage.copyToAppDirectory(pickedFile);
    final fileSize = await _fileStorage.getFileSize(copiedFile);
    final fileName = _fileStorage.getFileName(pickedFile.path);

    final now = DateTime.now();
    final document = Document(
      id: _uuid.v4(),
      title: fileName,
      filePath: copiedFile.path,
      fileSize: fileSize,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.insertDocument(document);
    return document;
  }
}
