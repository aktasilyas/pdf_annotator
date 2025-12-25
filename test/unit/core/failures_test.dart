/// Failures Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_annotator/core/errors/failures.dart';

void main() {
  group('Failures', () {
    group('DatabaseFailure', () {
      test('general should create failure with message', () {
        final failure = DatabaseFailure.general('Connection failed');
        expect(failure.message, contains('Connection failed'));
        expect(failure.code, 'DB_GENERAL');
      });

      test('notFound should include entity name', () {
        final failure = DatabaseFailure.notFound('Document');
        expect(failure.message, 'Document bulunamadı');
        expect(failure.code, 'DB_NOT_FOUND');
      });

      test('insertFailed should include entity name', () {
        final failure = DatabaseFailure.insertFailed('Annotation');
        expect(failure.message, 'Annotation eklenemedi');
        expect(failure.code, 'DB_INSERT_FAILED');
      });

      test('updateFailed should include entity name', () {
        final failure = DatabaseFailure.updateFailed('Document');
        expect(failure.message, 'Document güncellenemedi');
        expect(failure.code, 'DB_UPDATE_FAILED');
      });

      test('deleteFailed should include entity name', () {
        final failure = DatabaseFailure.deleteFailed('Annotation');
        expect(failure.message, 'Annotation silinemedi');
        expect(failure.code, 'DB_DELETE_FAILED');
      });
    });

    group('FileSystemFailure', () {
      test('notFound should have correct code', () {
        final failure = FileSystemFailure.notFound('/path/to/file');
        expect(failure.code, 'FS_NOT_FOUND');
      });

      test('readFailed should have correct code', () {
        final failure = FileSystemFailure.readFailed('timeout');
        expect(failure.message, contains('timeout'));
        expect(failure.code, 'FS_READ_FAILED');
      });

      test('writeFailed should have correct code', () {
        final failure = FileSystemFailure.writeFailed();
        expect(failure.code, 'FS_WRITE_FAILED');
      });

      test('copyFailed should have correct code', () {
        final failure = FileSystemFailure.copyFailed();
        expect(failure.code, 'FS_COPY_FAILED');
      });

      test('deleteFailed should have correct code', () {
        final failure = FileSystemFailure.deleteFailed();
        expect(failure.code, 'FS_DELETE_FAILED');
      });

      test('permissionDenied should have correct message', () {
        final failure = FileSystemFailure.permissionDenied();
        expect(failure.message, 'Dosya erişim izni reddedildi');
        expect(failure.code, 'FS_PERMISSION_DENIED');
      });

      test('invalidFormat should include expected format', () {
        final failure = FileSystemFailure.invalidFormat('PDF');
        expect(failure.message, contains('PDF'));
        expect(failure.code, 'FS_INVALID_FORMAT');
      });
    });

    group('PdfFailure', () {
      test('openFailed should have correct code', () {
        final failure = PdfFailure.openFailed();
        expect(failure.code, 'PDF_OPEN_FAILED');
      });

      test('corrupted should have correct message', () {
        final failure = PdfFailure.corrupted();
        expect(failure.message, contains('bozuk'));
        expect(failure.code, 'PDF_CORRUPTED');
      });

      test('pageNotFound should include page number', () {
        final failure = PdfFailure.pageNotFound(5);
        expect(failure.message, contains('5'));
        expect(failure.code, 'PDF_PAGE_NOT_FOUND');
      });

      test('passwordProtected should have correct message', () {
        final failure = PdfFailure.passwordProtected();
        expect(failure.message, contains('şifre'));
        expect(failure.code, 'PDF_PASSWORD_PROTECTED');
      });
    });

    group('AnnotationFailure', () {
      test('saveFailed should have correct message', () {
        final failure = AnnotationFailure.saveFailed();
        expect(failure.message, 'Çizim kaydedilemedi');
        expect(failure.code, 'ANN_SAVE_FAILED');
      });

      test('loadFailed should have correct message', () {
        final failure = AnnotationFailure.loadFailed();
        expect(failure.message, 'Çizimler yüklenemedi');
        expect(failure.code, 'ANN_LOAD_FAILED');
      });

      test('deleteFailed should have correct message', () {
        final failure = AnnotationFailure.deleteFailed();
        expect(failure.message, 'Çizim silinemedi');
        expect(failure.code, 'ANN_DELETE_FAILED');
      });
    });

    group('UnknownFailure', () {
      test('should have default message', () {
        final failure = UnknownFailure();
        expect(failure.message, 'Beklenmeyen bir hata oluştu');
        expect(failure.code, 'UNKNOWN');
      });
    });

    group('Equality', () {
      test('failures with same props should be equal', () {
        final failure1 = DatabaseFailure.notFound('Doc');
        final failure2 = DatabaseFailure.notFound('Doc');
        expect(failure1, equals(failure2));
      });

      test('failures with different props should not be equal', () {
        final failure1 = DatabaseFailure.notFound('Doc');
        final failure2 = DatabaseFailure.notFound('User');
        expect(failure1, isNot(equals(failure2)));
      });
    });
  });
}
