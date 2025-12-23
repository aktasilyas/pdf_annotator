import 'package:pdf_annotator/features/documents/data/datasources/document_local_datasource.dart';
import 'package:pdf_annotator/features/documents/data/models/document_model.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDatasource _datasource;

  DocumentRepositoryImpl(this._datasource);

  @override
  Future<List<Document>> getAllDocuments() async {
    final models = await _datasource.getAllDocuments();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Document?> getDocumentById(String id) async {
    final model = await _datasource.getDocumentById(id);
    return model?.toEntity();
  }

  @override
  Future<void> insertDocument(Document document) async {
    final model = DocumentModel.fromEntity(document);
    await _datasource.insertDocument(model);
  }

  @override
  Future<void> updateDocument(Document document) async {
    final model = DocumentModel.fromEntity(document);
    await _datasource.updateDocument(model);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _datasource.deleteDocument(id);
  }
}
