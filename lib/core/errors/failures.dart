/// Failures
///
/// Domain katmanında kullanılan hata sınıfları.
/// Exception'lardan farklı olarak, failure'lar beklenen hatalardır
/// ve UI'a gösterilmek üzere tasarlanmıştır.
///
/// Kullanım:
/// - Repository'ler Failure döner (throw etmez)
/// - UseCase'ler Failure'ı UI'a iletir
/// - UI Failure'a göre kullanıcıya mesaj gösterir
library;

import 'package:equatable/equatable.dart';

/// Base Failure sınıfı
/// Tüm failure tipleri bu sınıftan türer
abstract class Failure extends Equatable {
  /// Kullanıcıya gösterilecek hata mesajı
  final String message;

  /// Opsiyonel hata kodu (loglama için)
  final String? code;

  /// Orijinal hata (debug için)
  final dynamic originalError;

  const Failure({required this.message, this.code, this.originalError});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Database ile ilgili hatalar
///
/// Örnekler:
/// - Veritabanı açılamadı
/// - Sorgu başarısız
/// - Veri bulunamadı
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Genel database hatası
  factory DatabaseFailure.general([String? details]) {
    return DatabaseFailure(
      message: 'Veritabanı hatası oluştu${details != null ? ': $details' : ''}',
      code: 'DB_GENERAL',
    );
  }

  /// Veri bulunamadı
  factory DatabaseFailure.notFound(String entity) {
    return DatabaseFailure(message: '$entity bulunamadı', code: 'DB_NOT_FOUND');
  }

  /// Veri eklenemedi
  factory DatabaseFailure.insertFailed(String entity) {
    return DatabaseFailure(
      message: '$entity eklenemedi',
      code: 'DB_INSERT_FAILED',
    );
  }

  /// Veri güncellenemedi
  factory DatabaseFailure.updateFailed(String entity) {
    return DatabaseFailure(
      message: '$entity güncellenemedi',
      code: 'DB_UPDATE_FAILED',
    );
  }

  /// Veri silinemedi
  factory DatabaseFailure.deleteFailed(String entity) {
    return DatabaseFailure(
      message: '$entity silinemedi',
      code: 'DB_DELETE_FAILED',
    );
  }
}

/// Dosya sistemi ile ilgili hatalar
///
/// Örnekler:
/// - Dosya bulunamadı
/// - Dosya okunamadı
/// - Dosya yazılamadı
/// - İzin hatası
class FileSystemFailure extends Failure {
  const FileSystemFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Dosya bulunamadı
  factory FileSystemFailure.notFound(String path) {
    return FileSystemFailure(message: 'Dosya bulunamadı', code: 'FS_NOT_FOUND');
  }

  /// Dosya okunamadı
  factory FileSystemFailure.readFailed([String? details]) {
    return FileSystemFailure(
      message: 'Dosya okunamadı${details != null ? ': $details' : ''}',
      code: 'FS_READ_FAILED',
    );
  }

  /// Dosya yazılamadı
  factory FileSystemFailure.writeFailed([String? details]) {
    return FileSystemFailure(
      message: 'Dosya yazılamadı${details != null ? ': $details' : ''}',
      code: 'FS_WRITE_FAILED',
    );
  }

  /// Dosya kopyalanamadı
  factory FileSystemFailure.copyFailed([String? details]) {
    return FileSystemFailure(
      message: 'Dosya kopyalanamadı${details != null ? ': $details' : ''}',
      code: 'FS_COPY_FAILED',
    );
  }

  /// Dosya silinemedi
  factory FileSystemFailure.deleteFailed([String? details]) {
    return FileSystemFailure(
      message: 'Dosya silinemedi${details != null ? ': $details' : ''}',
      code: 'FS_DELETE_FAILED',
    );
  }

  /// İzin hatası
  factory FileSystemFailure.permissionDenied() {
    return const FileSystemFailure(
      message: 'Dosya erişim izni reddedildi',
      code: 'FS_PERMISSION_DENIED',
    );
  }

  /// Geçersiz dosya formatı
  factory FileSystemFailure.invalidFormat(String expected) {
    return FileSystemFailure(
      message: 'Geçersiz dosya formatı. Beklenen: $expected',
      code: 'FS_INVALID_FORMAT',
    );
  }
}

/// PDF işleme ile ilgili hatalar
///
/// Örnekler:
/// - PDF açılamadı
/// - PDF bozuk
/// - Sayfa bulunamadı
class PdfFailure extends Failure {
  const PdfFailure({required super.message, super.code, super.originalError});

  /// PDF açılamadı
  factory PdfFailure.openFailed([String? details]) {
    return PdfFailure(
      message: 'PDF açılamadı${details != null ? ': $details' : ''}',
      code: 'PDF_OPEN_FAILED',
    );
  }

  /// PDF bozuk
  factory PdfFailure.corrupted() {
    return const PdfFailure(
      message: 'PDF dosyası bozuk veya okunamıyor',
      code: 'PDF_CORRUPTED',
    );
  }

  /// Sayfa bulunamadı
  factory PdfFailure.pageNotFound(int pageNumber) {
    return PdfFailure(
      message: 'Sayfa $pageNumber bulunamadı',
      code: 'PDF_PAGE_NOT_FOUND',
    );
  }

  /// PDF şifreli
  factory PdfFailure.passwordProtected() {
    return const PdfFailure(
      message: 'PDF şifre korumalı',
      code: 'PDF_PASSWORD_PROTECTED',
    );
  }
}

/// Annotation işleme ile ilgili hatalar
class AnnotationFailure extends Failure {
  const AnnotationFailure({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Annotation kaydedilemedi
  factory AnnotationFailure.saveFailed() {
    return const AnnotationFailure(
      message: 'Çizim kaydedilemedi',
      code: 'ANN_SAVE_FAILED',
    );
  }

  /// Annotation yüklenemedi
  factory AnnotationFailure.loadFailed() {
    return const AnnotationFailure(
      message: 'Çizimler yüklenemedi',
      code: 'ANN_LOAD_FAILED',
    );
  }

  /// Annotation silinemedi
  factory AnnotationFailure.deleteFailed() {
    return const AnnotationFailure(
      message: 'Çizim silinemedi',
      code: 'ANN_DELETE_FAILED',
    );
  }
}

/// Bilinmeyen/beklenmeyen hatalar
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Beklenmeyen bir hata oluştu',
    super.code = 'UNKNOWN',
    super.originalError,
  });
}
