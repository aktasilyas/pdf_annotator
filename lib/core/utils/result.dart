/// Result Type
///
/// Fonksiyonların başarılı veya başarısız sonuçlarını
/// temsil etmek için kullanılan sealed class.
///
/// Either pattern'in basitleştirilmiş versiyonu.
/// Exception throw etmek yerine Result döndürülür.
///
/// Kullanım:
/// ```dart
/// Future<Result<Document>> importDocument(String path) async {
///   try {
///     final doc = await _import(path);
///     return Success(doc);
///   } catch (e) {
///     return Error(FileSystemFailure.readFailed());
///   }
/// }
///
/// // Kullanım
/// final result = await importDocument(path);
/// result.when(
///   success: (doc) => print('Imported: ${doc.title}'),
///   error: (failure) => print('Error: ${failure.message}'),
/// );
/// ```
library;

import 'package:pdf_annotator/core/errors/failures.dart' as failures;

/// Result sealed class
///
/// [T]: Başarılı sonuç tipi
sealed class Result<T> {
  const Result();

  /// Başarılı mı?
  bool get isSuccess => this is Success<T>;

  /// Başarısız mı?
  bool get isError => this is Error<T>;

  /// Pattern matching ile sonucu işle
  R when<R>({
    required R Function(T data) success,
    required R Function(failures.Failure failure) error,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    } else if (self is Error<T>) {
      return error(self.failure);
    }
    throw StateError('Unexpected Result type');
  }

  /// Başarılı ise data'yı döner, değilse null
  T? get dataOrNull {
    final self = this;
    if (self is Success<T>) {
      return self.data;
    }
    return null;
  }

  /// Başarısız ise failure'ı döner, değilse null
  failures.Failure? get failureOrNull {
    final self = this;
    if (self is Error<T>) {
      return self.failure;
    }
    return null;
  }

  /// Başarılı ise data'yı döner, değilse default değer döner
  T dataOr(T defaultValue) {
    final self = this;
    if (self is Success<T>) {
      return self.data;
    }
    return defaultValue;
  }

  /// Map fonksiyonu - başarılı sonucu dönüştürür
  Result<R> map<R>(R Function(T data) transform) {
    final self = this;
    if (self is Success<T>) {
      return Success(transform(self.data));
    }
    return Error((self as Error<T>).failure);
  }
}

/// Başarılı sonuç
class Success<T> extends Result<T> {
  /// Sonuç verisi
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Başarısız sonuç
class Error<T> extends Result<T> {
  /// Hata bilgisi
  final failures.Failure failure;

  const Error(this.failure);

  @override
  String toString() => 'Error(${failure.message})';
}
