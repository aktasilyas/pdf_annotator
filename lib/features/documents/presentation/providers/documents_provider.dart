import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_annotator/features/documents/data/datasources/document_local_datasource.dart';
import 'package:pdf_annotator/features/documents/data/repositories/document_repository_impl.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

// Datasource provider
final documentLocalDatasourceProvider = Provider<DocumentLocalDatasource>((
  ref,
) {
  return DocumentLocalDatasource();
});

// Repository provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final datasource = ref.watch(documentLocalDatasourceProvider);
  return DocumentRepositoryImpl(datasource);
});

// Documents state notifier
class DocumentsNotifier extends StateNotifier<AsyncValue<List<Document>>> {
  final DocumentRepository _repository;

  DocumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = const AsyncValue.loading();
    try {
      final documents = await _repository.getAllDocuments();
      state = AsyncValue.data(documents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDocument(Document document) async {
    try {
      await _repository.insertDocument(document);
      await loadDocuments();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _repository.deleteDocument(id);
      await loadDocuments();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDocument(Document document) async {
    try {
      await _repository.updateDocument(document);
      await loadDocuments();
    } catch (e) {
      rethrow;
    }
  }
}

// Main provider
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, AsyncValue<List<Document>>>((ref) {
      final repository = ref.watch(documentRepositoryProvider);
      return DocumentsNotifier(repository);
    });
