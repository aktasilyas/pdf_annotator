/// Test Helpers
library;

import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';

/// Test için örnek Document oluşturur
Document createTestDocument({
  String? id,
  String? title,
  String? filePath,
  int pageCount = 10,
  int currentPage = 1,
  int fileSize = 1024,
}) {
  final now = DateTime.now();
  return Document(
    id: id ?? 'test-doc-id',
    title: title ?? 'Test Document',
    filePath: filePath ?? '/path/to/test.pdf',
    pageCount: pageCount,
    currentPage: currentPage,
    fileSize: fileSize,
    createdAt: now,
    updatedAt: now,
  );
}

/// Test için örnek Point oluşturur
Point createTestPoint({
  double x = 100.0,
  double y = 200.0,
  double pressure = 1.0,
  int? timestamp,
}) {
  return Point(x: x, y: y, pressure: pressure, timestamp: timestamp);
}

/// Test için örnek Stroke oluşturur
Stroke createTestStroke({
  String? id,
  String documentId = 'test-doc-id',
  int pageNumber = 0,
  int color = 0xFF000000,
  double strokeWidth = 3.0,
  List<Point>? points,
}) {
  final now = DateTime.now();
  return Stroke(
    id: id ?? 'test-stroke-id',
    documentId: documentId,
    pageNumber: pageNumber,
    type: AnnotationType.stroke,
    color: color,
    strokeWidth: strokeWidth,
    opacity: 1.0,
    points:
        points ??
        [
          createTestPoint(x: 0, y: 0),
          createTestPoint(x: 50, y: 50),
          createTestPoint(x: 100, y: 100),
        ],
    createdAt: now,
    updatedAt: now,
  );
}

/// Test için örnek Highlight oluşturur
Highlight createTestHighlight({
  String? id,
  String documentId = 'test-doc-id',
  int pageNumber = 0,
  int color = 0xFFFFFF00,
  double strokeWidth = 20.0,
  List<Point>? points,
}) {
  final now = DateTime.now();
  return Highlight(
    id: id ?? 'test-highlight-id',
    documentId: documentId,
    pageNumber: pageNumber,
    type: AnnotationType.highlight,
    color: color,
    strokeWidth: strokeWidth,
    opacity: 0.4,
    points:
        points ?? [createTestPoint(x: 0, y: 0), createTestPoint(x: 100, y: 0)],
    createdAt: now,
    updatedAt: now,
  );
}
