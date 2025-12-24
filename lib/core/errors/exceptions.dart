/// Exceptions
///
/// Data katmanında kullanılan exception sınıfları.
/// Repository implementation'larında throw edilir
/// ve UseCase'lerde yakalanıp Failure'a dönüştürülür.
///
/// Kullanım:
/// - Datasource'lar exception throw eder
/// - Repository impl exception'ı yakalar
/// - Repository Failure döner
library;

/// Base Exception sınıfı
abstract class AppException implements Exception {
  /// Hata mesajı
  final String message;

  /// Orijinal hata
  final dynamic originalError;

  /// Stack trace
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Database exception
///
/// SQLite işlemlerinde oluşan hatalar için
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// File system exception
///
/// Dosya okuma/yazma/silme işlemlerinde oluşan hatalar için
class FileSystemException extends AppException {
  /// Hatalı dosya yolu
  final String? path;

  const FileSystemException({
    required super.message,
    this.path,
    super.originalError,
    super.stackTrace,
  });
}

/// PDF exception
///
/// PDF işleme hatalarında kullanılır
class PdfException extends AppException {
  const PdfException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Cache exception
///
/// Önbellek işlemlerinde oluşan hatalar için
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Validation exception
///
/// Veri doğrulama hatalarında kullanılır
class ValidationException extends AppException {
  /// Hatalı alan adı
  final String? field;

  const ValidationException({
    required super.message,
    this.field,
    super.originalError,
    super.stackTrace,
  });
}
