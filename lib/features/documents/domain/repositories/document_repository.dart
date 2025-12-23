import 'package:pdf_annotator/features/documents/domain/entities/document.dart';

abstract class DocumentRepository {
  Future<List<Document>> getAllDocuments();
  Future<Document?> getDocumentById(String id);
  Future<void> insertDocument(Document document);
  Future<void> updateDocument(Document document);
  Future<void> deleteDocument(String id);
}
