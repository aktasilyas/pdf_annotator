import 'dart:io';

import 'package:pdf_annotator/core/utils/file_utils.dart';
import 'package:pdf_annotator/features/documents/domain/services/file_storage_repository.dart';

// FileStorageRepository uygulaması: FileUtils kullanarak dosya işlerini yürütür.
class DocumentFileRepositoryImpl implements FileStorageRepository {
  const DocumentFileRepositoryImpl();

  /// Opens a PDF picker via FileUtils.
  @override
  Future<File?> pickPdfFile() {
    return FileUtils.pickPdfFile();
  }

  /// Copies the PDF to the app directory.
  @override
  Future<File> copyToAppDirectory(File file) {
    return FileUtils.copyToAppDirectory(file);
  }

  /// Deletes the file if present.
  @override
  Future<void> deleteFile(String filePath) {
    return FileUtils.deleteFile(filePath);
  }

  /// Gets the file size in bytes.
  @override
  Future<int> getFileSize(File file) {
    return FileUtils.getFileSize(file);
  }

  /// Returns the base name without extension.
  @override
  String getFileName(String filePath) {
    return FileUtils.getFileName(filePath);
  }
}
