/// Import Document UseCase
///
/// PDF dosyası import etme işlemini yönetir.
/// Dosya seçimi, kopyalama ve kaydetme adımlarını içerir.
library;

import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/domain/repositories/document_repository.dart';

class ImportDocumentUseCase {
  final DocumentRepository _repository;

  const ImportDocumentUseCase(this._repository);

  /// Dokümanı veritabanına kaydeder
  ///
  /// [document]: Kaydedilecek doküman
  ///
  /// Returns: Result<void>
  /// - Success: İşlem başarılı
  /// - Error: Hata bilgisi
  Future<Result<void>> call(Document document) {
    return _repository.insertDocument(document);
  }
}
