/// Result Type Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_annotator/core/utils/result.dart';
import 'package:pdf_annotator/core/errors/failures.dart';

void main() {
  group('Result Type', () {
    group('Success', () {
      test('isSuccess should return true', () {
        final result = Success<String>('data');
        expect(result.isSuccess, true);
        expect(result.isError, false);
      });

      test('dataOrNull should return data', () {
        final result = Success<String>('hello');
        expect(result.dataOrNull, 'hello');
      });

      test('failureOrNull should return null', () {
        final result = Success<String>('hello');
        expect(result.failureOrNull, isNull);
      });

      test('when should call success callback', () {
        final result = Success<int>(42);
        String? successValue;
        String? errorValue;

        result.when(
          success: (data) => successValue = 'Got: $data',
          error: (failure) => errorValue = failure.message,
        );

        expect(successValue, 'Got: 42');
        expect(errorValue, isNull);
      });
    });

    group('Error', () {
      test('isError should return true', () {
        final result = Error<String>(DatabaseFailure.general());
        expect(result.isError, true);
        expect(result.isSuccess, false);
      });

      test('dataOrNull should return null', () {
        final result = Error<String>(DatabaseFailure.general());
        expect(result.dataOrNull, isNull);
      });

      test('failureOrNull should return failure', () {
        final failure = DatabaseFailure.notFound('Document');
        final result = Error<String>(failure);
        expect(result.failureOrNull, failure);
      });

      test('when should call error callback', () {
        final result = Error<int>(DatabaseFailure.general('Test error'));
        String? successValue;
        String? errorValue;

        result.when(
          success: (data) => successValue = 'Got: $data',
          error: (failure) => errorValue = failure.message,
        );

        expect(successValue, isNull);
        expect(errorValue, contains('Test error'));
      });
    });

    group('dataOr', () {
      test('should return data on success', () {
        final result = Success<int>(42);
        expect(result.dataOr(0), 42);
      });

      test('should return default on error', () {
        final result = Error<int>(DatabaseFailure.general());
        expect(result.dataOr(0), 0);
      });
    });

    group('map', () {
      test('should transform success value', () {
        final result = Success<int>(10);
        final mapped = result.map((x) => x * 2);
        expect(mapped.dataOrNull, 20);
      });

      test('should keep error on error result', () {
        final failure = DatabaseFailure.general();
        final result = Error<int>(failure);
        final mapped = result.map((x) => x * 2);
        expect(mapped.isError, true);
        expect(mapped.failureOrNull, failure);
      });
    });
  });
}
