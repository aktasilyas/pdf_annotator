import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/presentation/providers/documents_provider.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  final Document document;

  const ViewerScreen({super.key, required this.document});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  late PdfViewerController _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _currentPage = widget.document.currentPage > 0
        ? widget.document.currentPage
        : 1;
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title, overflow: TextOverflow.ellipsis),
        actions: [
          // Sayfa numarası
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(widget.document.filePath),
        controller: _pdfController,
        onDocumentLoaded: (details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
          // Kayıtlı sayfaya git
          if (widget.document.currentPage > 1) {
            _pdfController.jumpToPage(widget.document.currentPage);
          }
          // Sayfa sayısını güncelle
          _updateDocumentPageCount(details.document.pages.count);
        },
        onPageChanged: (details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
          // Mevcut sayfayı kaydet
          _saveCurrentPage(details.newPageNumber);
        },
      ),
    );
  }

  void _updateDocumentPageCount(int pageCount) {
    if (widget.document.pageCount != pageCount) {
      final updated = widget.document.copyWith(
        pageCount: pageCount,
        updatedAt: DateTime.now(),
      );
      ref.read(documentsProvider.notifier).updateDocument(updated);
    }
  }

  void _saveCurrentPage(int page) {
    final updated = widget.document.copyWith(
      currentPage: page,
      lastOpenedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(documentsProvider.notifier).updateDocument(updated);
  }
}
