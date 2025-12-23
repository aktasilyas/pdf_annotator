/// Annotation Model
///
/// Annotation entity'sinin data layer karşılığı.
/// Database CRUD işlemlerinde kullanılır.
/// Points listesi JSON string olarak saklanır.
library;

import 'dart:convert';
import 'package:pdf_annotator/features/annotations/data/models/point_model.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

class AnnotationModel {
  /// Unique identifier
  final String id;

  /// Doküman ID
  final String documentId;

  /// Sayfa numarası
  final int pageNumber;

  /// Annotation tipi
  final AnnotationType type;

  /// Renk (ARGB)
  final int color;

  /// Çizgi kalınlığı
  final double strokeWidth;

  /// Opaklık
  final double opacity;

  /// Noktalar listesi
  final List<PointModel> points;

  /// Oluşturulma zamanı
  final DateTime createdAt;

  /// Güncellenme zamanı
  final DateTime updatedAt;

  /// Soft delete flag
  final bool isDeleted;

  /// Katman sırası
  final int zIndex;

  const AnnotationModel({
    required this.id,
    required this.documentId,
    required this.pageNumber,
    required this.type,
    required this.color,
    required this.strokeWidth,
    required this.opacity,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.zIndex = 0,
  });

  /// Database Map'ten AnnotationModel oluşturur
  factory AnnotationModel.fromMap(Map<String, dynamic> map) {
    // Points JSON string olarak saklanıyor
    final pointsJson = map['points'] as String;
    final pointsList = (jsonDecode(pointsJson) as List)
        .map((p) => PointModel.fromMap(p as Map<String, dynamic>))
        .toList();

    return AnnotationModel(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      pageNumber: map['page_number'] as int,
      type: AnnotationTypeExtension.fromDbString(map['type'] as String),
      color: map['color'] as int,
      strokeWidth: (map['stroke_width'] as num).toDouble(),
      opacity: (map['opacity'] as num).toDouble(),
      points: pointsList,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isDeleted: (map['is_deleted'] as int) == 1,
      zIndex: map['z_index'] as int? ?? 0,
    );
  }

  /// AnnotationModel'i Database Map'e çevirir
  Map<String, dynamic> toMap() {
    // Points'i JSON string'e çevir
    final pointsJson = jsonEncode(points.map((p) => p.toMap()).toList());

    return {
      'id': id,
      'document_id': documentId,
      'page_number': pageNumber,
      'type': type.toDbString(),
      'color': color,
      'stroke_width': strokeWidth,
      'opacity': opacity,
      'points': pointsJson,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'z_index': zIndex,
    };
  }

  /// Stroke entity'den Model oluşturur
  factory AnnotationModel.fromStroke(Stroke stroke) {
    return AnnotationModel(
      id: stroke.id,
      documentId: stroke.documentId,
      pageNumber: stroke.pageNumber,
      type: stroke.type,
      color: stroke.color,
      strokeWidth: stroke.strokeWidth,
      opacity: stroke.opacity,
      points: stroke.points.map((p) => PointModel.fromEntity(p)).toList(),
      createdAt: stroke.createdAt,
      updatedAt: stroke.updatedAt,
      isDeleted: stroke.isDeleted,
      zIndex: stroke.zIndex,
    );
  }

  /// Highlight entity'den Model oluşturur
  factory AnnotationModel.fromHighlight(Highlight highlight) {
    return AnnotationModel(
      id: highlight.id,
      documentId: highlight.documentId,
      pageNumber: highlight.pageNumber,
      type: highlight.type,
      color: highlight.color,
      strokeWidth: highlight.strokeWidth,
      opacity: highlight.opacity,
      points: highlight.points.map((p) => PointModel.fromEntity(p)).toList(),
      createdAt: highlight.createdAt,
      updatedAt: highlight.updatedAt,
      isDeleted: highlight.isDeleted,
      zIndex: highlight.zIndex,
    );
  }

  /// Model'i Stroke entity'ye çevirir
  Stroke toStroke() {
    return Stroke(
      id: id,
      documentId: documentId,
      pageNumber: pageNumber,
      type: type,
      color: color,
      strokeWidth: strokeWidth,
      opacity: opacity,
      points: points.map((p) => p.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      zIndex: zIndex,
    );
  }

  /// Model'i Highlight entity'ye çevirir
  Highlight toHighlight() {
    return Highlight(
      id: id,
      documentId: documentId,
      pageNumber: pageNumber,
      type: type,
      color: color,
      strokeWidth: strokeWidth,
      opacity: opacity,
      points: points.map((p) => p.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      zIndex: zIndex,
    );
  }

  /// Type'a göre uygun entity'ye çevirir
  dynamic toEntity() {
    switch (type) {
      case AnnotationType.stroke:
        return toStroke();
      case AnnotationType.highlight:
        return toHighlight();
      case AnnotationType.textNote:
        // Post-MVP
        return toStroke();
    }
  }
}
