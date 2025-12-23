import 'package:equatable/equatable.dart';

class Document extends Equatable {
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

  const Document({
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

  Document copyWith({
    String? id,
    String? title,
    String? filePath,
    String? thumbnailPath,
    int? pageCount,
    int? currentPage,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    filePath,
    thumbnailPath,
    pageCount,
    currentPage,
    fileSize,
    createdAt,
    updatedAt,
    lastOpenedAt,
  ];
}
