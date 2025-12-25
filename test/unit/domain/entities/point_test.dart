/// Point Entity Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';

void main() {
  group('Point Entity', () {
    test('should create point with x, y coordinates', () {
      // Arrange & Act
      final point = Point(x: 150.0, y: 250.0);

      // Assert
      expect(point.x, 150.0);
      expect(point.y, 250.0);
    });

    test('should have default pressure of 1.0', () {
      // Arrange & Act
      final point = Point(x: 0, y: 0);

      // Assert
      expect(point.pressure, 1.0);
    });

    test('should support custom pressure value', () {
      // Arrange & Act
      final point = Point(x: 0, y: 0, pressure: 0.5);

      // Assert
      expect(point.pressure, 0.5);
    });

    test('should support equality comparison', () {
      // Arrange
      final point1 = Point(x: 10, y: 20, pressure: 1.0);
      final point2 = Point(x: 10, y: 20, pressure: 1.0);
      final point3 = Point(x: 30, y: 40, pressure: 1.0);

      // Assert
      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });

    test('copyWith should create new instance', () {
      // Arrange
      final original = Point(x: 10, y: 20);

      // Act
      final updated = original.copyWith(x: 30);

      // Assert
      expect(original.x, 10);
      expect(updated.x, 30);
      expect(updated.y, 20);
    });
  });
}
