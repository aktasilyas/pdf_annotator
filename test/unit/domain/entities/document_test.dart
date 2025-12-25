/// Document Entity Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';

void main() {
  group('Document Entity', () {
    /// Test için Document oluşturur
    Document createDocument({
      String id = 'test-id',
      String title = 'Test Doc',
      int pageCount = 10,
      int currentPage = 1,
    }) {
      final now = DateTime.now();
      return Document(
        id: id,
        title: title,
        filePath: '/path/to/test.pdf',
        pageCount: pageCount,
        currentPage: currentPage,
        fileSize: 1024,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('should create document with required fields', () {
      // Arrange & Act
      final document = createDocument(id: 'doc-123', title: 'My PDF');

      // Assert
      expect(document.id, 'doc-123');
      expect(document.title, 'My PDF');
      expect(document.pageCount, 10);
    });

    test('should support equality comparison', () {
      // Arrange
      final now = DateTime(2024, 1, 1);
      final doc1 = Document(
        id: 'doc-1',
        title: 'Same',
        filePath: '/path.pdf',
        createdAt: now,
        updatedAt: now,
      );
      final doc2 = Document(
        id: 'doc-1',
        title: 'Same',
        filePath: '/path.pdf',
        createdAt: now,
        updatedAt: now,
      );
      final doc3 = createDocument(id: 'doc-2', title: 'Different');

      // Assert
      expect(doc1, equals(doc2));
      expect(doc1, isNot(equals(doc3)));
    });

    test('copyWith should create new instance with updated values', () {
      // Arrange
      final original = createDocument(title: 'Original');

      // Act
      final updated = original.copyWith(title: 'Updated');

      // Assert
      expect(original.title, 'Original');
      expect(updated.title, 'Updated');
      expect(updated.id, original.id);
    });

    test('copyWith should keep original values when not specified', () {
      // Arrange
      final original = createDocument(
        title: 'Original',
        pageCount: 50,
        currentPage: 5,
      );

      // Act
      final updated = original.copyWith(currentPage: 10);

      // Assert
      expect(updated.title, 'Original');
      expect(updated.pageCount, 50);
      expect(updated.currentPage, 10);
    });
  });
}
