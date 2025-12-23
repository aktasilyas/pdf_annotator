/// Viewer Screen
///
/// PDF görüntüleme ekranı.
/// Özellikler:
/// - PDF render (sayfa sayfa veya continuous)
/// - Zoom / Pan (pinch gesture)
/// - Page indicator (mevcut/toplam)
/// - Page navigation (önceki/sonraki butonları)
/// - Sayfa atlama dialog'u
/// - Son görüntülenen sayfa kaydı
library;

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
  /// PDF controller - sayfa navigasyonu için
  late PdfViewerController _pdfController;

  /// Mevcut sayfa numarası
  int _currentPage = 1;

  /// Toplam sayfa sayısı
  int _totalPages = 0;

  /// Zoom seviyesi
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    // Kayıtlı sayfadan başla
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
      appBar: _buildAppBar(),
      body: _buildPdfViewer(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// App bar - başlık ve menü
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.document.title, overflow: TextOverflow.ellipsis),
      actions: [
        // Sayfa atlama butonu
        IconButton(
          icon: const Icon(Icons.find_in_page),
          tooltip: 'Sayfaya Git',
          onPressed: _showGoToPageDialog,
        ),
        // Zoom göstergesi
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${(_zoomLevel * 100).toInt()}%',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        // Daha fazla seçenek
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'fit_page',
              child: Text('Sayfaya Sığdır'),
            ),
            const PopupMenuItem(
              value: 'fit_width',
              child: Text('Genişliğe Sığdır'),
            ),
            const PopupMenuItem(value: 'zoom_100', child: Text('100%')),
          ],
        ),
      ],
    );
  }

  /// PDF viewer widget
  Widget _buildPdfViewer() {
    return SfPdfViewer.file(
      File(widget.document.filePath),
      controller: _pdfController,
      pageLayoutMode: PdfPageLayoutMode.single, // Sayfa sayfa görünüm
      scrollDirection: PdfScrollDirection.horizontal, // Yatay kaydırma
      canShowScrollHead: true,
      canShowScrollStatus: true,
      onDocumentLoaded: _onDocumentLoaded,
      onPageChanged: _onPageChanged,
      onZoomLevelChanged: _onZoomChanged,
    );
  }

  /// Alt navigation bar
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Önceki sayfa butonu
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Önceki Sayfa',
              onPressed: _currentPage > 1 ? _goToPreviousPage : null,
            ),

            // Sayfa göstergesi (tıklanabilir)
            GestureDetector(
              onTap: _showGoToPageDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),

            // Sonraki sayfa butonu
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Sonraki Sayfa',
              onPressed: _currentPage < _totalPages ? _goToNextPage : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Doküman yüklendiğinde çağrılır
  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
    });

    // Kayıtlı sayfaya git
    if (widget.document.currentPage > 1 &&
        widget.document.currentPage <= _totalPages) {
      _pdfController.jumpToPage(widget.document.currentPage);
    }

    // Sayfa sayısını güncelle (değiştiyse)
    _updateDocumentPageCount(details.document.pages.count);
  }

  /// Sayfa değiştiğinde çağrılır
  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
    });

    // Mevcut sayfayı kaydet
    _saveCurrentPage(details.newPageNumber);
  }

  /// Zoom değiştiğinde çağrılır
  void _onZoomChanged(PdfZoomDetails details) {
    setState(() {
      _zoomLevel = details.newZoomLevel;
    });
  }

  /// Önceki sayfaya git
  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfController.previousPage();
    }
  }

  /// Sonraki sayfaya git
  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _pdfController.nextPage();
    }
  }

  /// Belirli bir sayfaya git
  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pdfController.jumpToPage(page);
    }
  }

  /// Sayfa atlama dialog'u
  void _showGoToPageDialog() {
    final controller = TextEditingController(text: _currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayfaya Git'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Sayfa numarası',
            hintText: '1 - $_totalPages',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final page = int.tryParse(value);
            if (page != null) {
              Navigator.pop(context);
              _goToPage(page);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null) {
                Navigator.pop(context);
                _goToPage(page);
              }
            },
            child: const Text('Git'),
          ),
        ],
      ),
    );
  }

  /// Menü aksiyonlarını işle
  void _handleMenuAction(String action) {
    switch (action) {
      case 'fit_page':
        _pdfController.zoomLevel = 1.0;
        break;
      case 'fit_width':
        _pdfController.zoomLevel = 1.5;
        break;
      case 'zoom_100':
        _pdfController.zoomLevel = 1.0;
        break;
    }
  }

  /// Dokümanın sayfa sayısını güncelle
  void _updateDocumentPageCount(int pageCount) {
    if (widget.document.pageCount != pageCount) {
      final updated = widget.document.copyWith(
        pageCount: pageCount,
        updatedAt: DateTime.now(),
      );
      ref.read(documentsProvider.notifier).updateDocument(updated);
    }
  }

  /// Mevcut sayfayı kaydet
  void _saveCurrentPage(int page) {
    final updated = widget.document.copyWith(
      currentPage: page,
      lastOpenedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(documentsProvider.notifier).updateDocument(updated);
  }
}
