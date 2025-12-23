import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_annotator/features/documents/data/datasources/document_file_repository_impl.dart';
import 'package:pdf_annotator/features/documents/data/datasources/document_local_datasource.dart';
import 'package:pdf_annotator/features/documents/data/repositories/document_repository_impl.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';
import 'package:pdf_annotator/features/documents/domain/services/file_storage_repository.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/delete_document_usecase.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/get_documents_usecase.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/import_document_usecase.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/update_document_usecase.dart';

// Datasource provider
final documentLocalDatasourceProvider = Provider<DocumentLocalDatasource>((
  ref,
) {
  return DocumentLocalDatasource();
});

// File storage provider
final fileStorageRepositoryProvider = Provider<FileStorageRepository>((ref) {
  return const DocumentFileRepositoryImpl();
});

// Repository provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final datasource = ref.watch(documentLocalDatasourceProvider);
  return DocumentRepositoryImpl(datasource);
});

// Usecase providers
final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return GetDocumentsUseCase(repository);
});

final importDocumentUseCaseProvider = Provider<ImportDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final fileStorage = ref.watch(fileStorageRepositoryProvider);
  return ImportDocumentUseCase(repository, fileStorage);
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final fileStorage = ref.watch(fileStorageRepositoryProvider);
  return DeleteDocumentUseCase(repository, fileStorage);
});

final updateDocumentUseCaseProvider = Provider<UpdateDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UpdateDocumentUseCase(repository);
});

// Documents state notifier
class DocumentsNotifier extends StateNotifier<AsyncValue<List<Document>>> {
  final GetDocumentsUseCase _getDocuments;
  final ImportDocumentUseCase _importDocument;
  final DeleteDocumentUseCase _deleteDocument;
  final UpdateDocumentUseCase _updateDocument;

  DocumentsNotifier({
    required GetDocumentsUseCase getDocuments,
    required ImportDocumentUseCase importDocument,
    required DeleteDocumentUseCase deleteDocument,
    required UpdateDocumentUseCase updateDocument,
  })  : _getDocuments = getDocuments,
        _importDocument = importDocument,
        _deleteDocument = deleteDocument,
        _updateDocument = updateDocument,
        super(const AsyncValue.loading()) {
          loadDocuments();
        }

  Future<void> loadDocuments() async {
    state = const AsyncValue.loading();
    try {
      final documents = await _getDocuments();
      state = AsyncValue.data(documents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Document?> importDocument() async {
    final newDocument = await _importDocument();
    if (newDocument != null) {
      await loadDocuments();
    }
    return newDocument;
  }

  Future<void> deleteDocument(Document document) async {
    await _deleteDocument(document);
    state = state.when(
      data: (docs) =>
          AsyncValue.data(docs.where((d) => d.id != document.id).toList()),
      loading: () => const AsyncValue.loading(),
      error: (error, st) => state,
    );
  }

  Future<void> updateDocument(Document document) async {
    await _updateDocument(document);
    state = state.when(
      data: (docs) {
        return AsyncValue.data(
          docs.map((d) => d.id == document.id ? document : d).toList(),
        );
      },
      loading: () => const AsyncValue.loading(),
      error: (error, st) => state,
    );
  }
}

// Main provider
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, AsyncValue<List<Document>>>((ref) {
      final getDocuments = ref.watch(getDocumentsUseCaseProvider);
      final importDocument = ref.watch(importDocumentUseCaseProvider);
      final deleteDocument = ref.watch(deleteDocumentUseCaseProvider);
      final updateDocument = ref.watch(updateDocumentUseCaseProvider);
      return DocumentsNotifier(
        getDocuments: getDocuments,
        importDocument: importDocument,
        deleteDocument: deleteDocument,
        updateDocument: updateDocument,
      );
    });
