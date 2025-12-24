/// Documents Provider
///
/// Document state management.
/// UseCase'ler üzerinden işlemleri yönetir.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_annotator/core/utils/logger.dart';
import 'package:pdf_annotator/features/documents/data/datasources/document_local_datasource.dart';
import 'package:pdf_annotator/features/documents/data/repositories/document_repository_impl.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/get_documents_usecase.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/import_document_usecase.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/update_document_usecase.dart';
import 'package:pdf_annotator/features/documents/domain/usecases/delete_document_usecase.dart';

// ============================================================================
// Providers
// ============================================================================

/// Datasource provider
final documentLocalDatasourceProvider = Provider<DocumentLocalDatasource>((
  ref,
) {
  return DocumentLocalDatasource();
});

/// Repository provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final datasource = ref.watch(documentLocalDatasourceProvider);
  return DocumentRepositoryImpl(datasource);
});

/// UseCase providers
final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return GetDocumentsUseCase(repository);
});

final importDocumentUseCaseProvider = Provider<ImportDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return ImportDocumentUseCase(repository);
});

final updateDocumentUseCaseProvider = Provider<UpdateDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return UpdateDocumentUseCase(repository);
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DeleteDocumentUseCase(repository);
});

// ============================================================================
// State
// ============================================================================

/// Documents state
class DocumentsState {
  final bool isLoading;
  final List<Document> documents;
  final String? errorMessage;

  const DocumentsState({
    this.isLoading = false,
    this.documents = const [],
    this.errorMessage,
  });

  factory DocumentsState.initial() {
    return const DocumentsState(isLoading: true);
  }

  DocumentsState copyWithLoading() {
    return DocumentsState(
      isLoading: true,
      documents: documents,
      errorMessage: null,
    );
  }

  DocumentsState copyWithData(List<Document> data) {
    return DocumentsState(
      isLoading: false,
      documents: data,
      errorMessage: null,
    );
  }

  DocumentsState copyWithError(String message) {
    return DocumentsState(
      isLoading: false,
      documents: documents,
      errorMessage: message,
    );
  }
}

// ============================================================================
// Notifier
// ============================================================================

/// Documents Notifier
class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final GetDocumentsUseCase _getDocumentsUseCase;
  final ImportDocumentUseCase _importDocumentUseCase;
  final UpdateDocumentUseCase _updateDocumentUseCase;
  final DeleteDocumentUseCase _deleteDocumentUseCase;

  DocumentsNotifier({
    required GetDocumentsUseCase getDocumentsUseCase,
    required ImportDocumentUseCase importDocumentUseCase,
    required UpdateDocumentUseCase updateDocumentUseCase,
    required DeleteDocumentUseCase deleteDocumentUseCase,
  }) : _getDocumentsUseCase = getDocumentsUseCase,
       _importDocumentUseCase = importDocumentUseCase,
       _updateDocumentUseCase = updateDocumentUseCase,
       _deleteDocumentUseCase = deleteDocumentUseCase,
       super(DocumentsState.initial()) {
    loadDocuments();
  }

  /// Tüm dokümanları yükle
  Future<void> loadDocuments() async {
    state = state.copyWithLoading();

    final result = await _getDocumentsUseCase();

    result.when(
      success: (documents) {
        state = state.copyWithData(documents);
      },
      error: (failure) {
        logger.error('Load documents failed: ${failure.message}');
        state = state.copyWithError(failure.message);
      },
    );
  }

  /// Yeni doküman ekle
  Future<bool> addDocument(Document document) async {
    final result = await _importDocumentUseCase(document);

    return result.when(
      success: (_) {
        loadDocuments();
        return true;
      },
      error: (failure) {
        logger.error('Add document failed: ${failure.message}');
        state = state.copyWithError(failure.message);
        return false;
      },
    );
  }

  /// Doküman güncelle
  Future<bool> updateDocument(Document document) async {
    final result = await _updateDocumentUseCase(document);

    return result.when(
      success: (_) {
        loadDocuments();
        return true;
      },
      error: (failure) {
        logger.error('Update document failed: ${failure.message}');
        state = state.copyWithError(failure.message);
        return false;
      },
    );
  }

  /// Doküman sil
  Future<bool> deleteDocument(String id) async {
    final result = await _deleteDocumentUseCase(id);

    return result.when(
      success: (_) {
        loadDocuments();
        return true;
      },
      error: (failure) {
        logger.error('Delete document failed: ${failure.message}');
        state = state.copyWithError(failure.message);
        return false;
      },
    );
  }

  /// Error mesajını temizle
  void clearError() {
    state = DocumentsState(
      isLoading: state.isLoading,
      documents: state.documents,
      errorMessage: null,
    );
  }
}

// ============================================================================
// Main Provider
// ============================================================================

/// Main documents provider
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
      return DocumentsNotifier(
        getDocumentsUseCase: ref.watch(getDocumentsUseCaseProvider),
        importDocumentUseCase: ref.watch(importDocumentUseCaseProvider),
        updateDocumentUseCase: ref.watch(updateDocumentUseCaseProvider),
        deleteDocumentUseCase: ref.watch(deleteDocumentUseCaseProvider),
      );
    });
