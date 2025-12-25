/// Stroke Entity Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';

void main() {
  group('Stroke Entity', () {
    /// Test için Stroke oluşturur
    Stroke createStroke({
      String id = 'test-stroke-id',
      String documentId = 'test-doc-id',
      int pageNumber = 0,
      int color = 0xFF000000,
      double strokeWidth = 3.0,
      List<Point>? points,
    }) {
      final now = DateTime.now();
      return Stroke(
        id: id,
        documentId: documentId,
        pageNumber: pageNumber,
        type: AnnotationType.stroke,
        color: color,
        strokeWidth: strokeWidth,
        opacity: 1.0,
        points:
            points ??
            [Point(x: 0, y: 0), Point(x: 50, y: 50), Point(x: 100, y: 100)],
        createdAt: now,
        updatedAt: now,
      );
    }

    test('should create stroke with required fields', () {
      // Arrange & Act
      final stroke = createStroke(
        id: 'stroke-123',
        documentId: 'doc-456',
        pageNumber: 2,
      );

      // Assert
      expect(stroke.id, 'stroke-123');
      expect(stroke.documentId, 'doc-456');
      expect(stroke.pageNumber, 2);
      expect(stroke.type, AnnotationType.stroke);
    });

    test('should have default opacity of 1.0', () {
      // Arrange & Act
      final stroke = createStroke();

      // Assert
      expect(stroke.opacity, 1.0);
    });

    test('isEmpty should return true for empty points', () {
      // Arrange
      final stroke = createStroke(points: []);

      // Assert
      expect(stroke.isEmpty, true);
    });

    test('isEmpty should return false when has points', () {
      // Arrange
      final stroke = createStroke();

      // Assert
      expect(stroke.isEmpty, false);
    });

    test('addPoint should return new stroke with added point', () {
      // Arrange
      final original = createStroke(points: [Point(x: 0, y: 0)]);
      final newPoint = Point(x: 50, y: 50);

      // Act
      final updated = original.addPoint(newPoint);

      // Assert
      expect(original.points.length, 1);
      expect(updated.points.length, 2);
      expect(updated.points.last, newPoint);
    });

    test('boundingBox should calculate correct bounds', () {
      // Arrange
      final stroke = createStroke(
        points: [Point(x: 10, y: 20), Point(x: 50, y: 80), Point(x: 30, y: 40)],
      );

      // Act
      final bounds = stroke.boundingBox;

      // Assert
      expect(bounds, isNotNull);
      expect(bounds!.$1, 10); // minX
      expect(bounds.$2, 20); // minY
      expect(bounds.$3, 50); // maxX
      expect(bounds.$4, 80); // maxY
    });

    test('boundingBox should return null for empty stroke', () {
      // Arrange
      final stroke = createStroke(points: []);

      // Assert
      expect(stroke.boundingBox, isNull);
    });
  });
}
