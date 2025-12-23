import 'dart:io';

// File storage port: documents özelliğinin ihtiyaç duyduğu dosya işlemlerini
// soyutlar, böylece domain/presentation katmanları platform bağımlı koda
// dokunmaz.
abstract class FileStorageRepository {
  /// Opens a picker and returns the selected PDF or null if cancelled.
  Future<File?> pickPdfFile();

  /// Copies the given file into the app's sandbox directory.
  Future<File> copyToAppDirectory(File file);

  /// Deletes the file at the provided path if it exists.
  Future<void> deleteFile(String filePath);

  /// Returns the file size in bytes.
  Future<int> getFileSize(File file);

  /// Returns the base file name without extension.
  String getFileName(String filePath);
}
