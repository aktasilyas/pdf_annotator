import 'package:pdf_annotator/database/database_service.dart';
import 'package:pdf_annotator/features/documents/data/models/document_model.dart';

class DocumentLocalDatasource {
  Future<List<DocumentModel>> getAllDocuments() async {
    final db = DatabaseService.instance;
    final result = await db.query('documents', orderBy: 'updated_at DESC');
    return result.map((map) => DocumentModel.fromMap(map)).toList();
  }

  Future<DocumentModel?> getDocumentById(String id) async {
    final db = DatabaseService.instance;
    final result = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DocumentModel.fromMap(result.first);
  }

  Future<void> insertDocument(DocumentModel document) async {
    final db = DatabaseService.instance;
    await db.insert('documents', document.toMap());
  }

  Future<void> updateDocument(DocumentModel document) async {
    final db = DatabaseService.instance;
    await db.update(
      'documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  Future<void> deleteDocument(String id) async {
    final db = DatabaseService.instance;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }
}
