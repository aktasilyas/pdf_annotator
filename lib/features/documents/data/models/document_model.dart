import 'package:pdf_annotator/features/documents/domain/entities/document.dart';

class DocumentModel {
  final String id;
  final String title;
  final String filePath;
  final String? thumbnailPath;
  final int pageCount;
  final int currentPage;
  final int fileSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.filePath,
    this.thumbnailPath,
    this.pageCount = 0,
    this.currentPage = 0,
    this.fileSize = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
  });

  // Database'den okurken
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      pageCount: map['page_count'] as int? ?? 0,
      currentPage: map['current_page'] as int? ?? 0,
      fileSize: map['file_size'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastOpenedAt: map['last_opened_at'] != null
          ? DateTime.parse(map['last_opened_at'] as String)
          : null,
    );
  }

  // Database'e yazarken
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'page_count': pageCount,
      'current_page': currentPage,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_opened_at': lastOpenedAt?.toIso8601String(),
    };
  }

  // Model -> Entity
  Document toEntity() {
    return Document(
      id: id,
      title: title,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      pageCount: pageCount,
      currentPage: currentPage,
      fileSize: fileSize,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastOpenedAt: lastOpenedAt,
    );
  }

  // Entity -> Model
  factory DocumentModel.fromEntity(Document entity) {
    return DocumentModel(
      id: entity.id,
      title: entity.title,
      filePath: entity.filePath,
      thumbnailPath: entity.thumbnailPath,
      pageCount: entity.pageCount,
      currentPage: entity.currentPage,
      fileSize: entity.fileSize,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastOpenedAt: entity.lastOpenedAt,
    );
  }
}
