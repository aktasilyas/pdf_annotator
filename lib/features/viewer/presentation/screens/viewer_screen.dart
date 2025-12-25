/// Viewer Screen
///
/// PDF görüntüleme + çizim ekranı.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/presentation/providers/documents_provider.dart';
import 'package:pdf_annotator/features/annotations/presentation/widgets/drawing_canvas.dart';
import 'package:pdf_annotator/features/annotations/presentation/widgets/floating_toolbar.dart';
import 'package:pdf_annotator/features/annotations/presentation/providers/drawing_provider.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_tool.dart';

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
    final controller = ref.watch(drawingControllerProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // PDF + Canvas + Navigation
          Column(
            children: [
              Expanded(child: _buildPdfWithCanvas(controller)),
              _buildNavigationBar(),
            ],
          ),

          // Floating Toolbar (sürüklenebilir)
          FloatingToolbar(
            documentId: widget.document.id,
            pageNumber: _currentPage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.document.title, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(
          icon: const Icon(Icons.find_in_page),
          tooltip: 'Sayfaya Git',
          onPressed: _showGoToPageDialog,
        ),
      ],
    );
  }

  Widget _buildPdfWithCanvas(DrawingController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDrawingMode = controller.selectedTool != DrawingTool.none;

        return Stack(
          children: [
            // PDF Viewer (altta)
            AbsorbPointer(
              absorbing: isDrawingMode,
              child: SfPdfViewer.file(
                File(widget.document.filePath),
                controller: _pdfController,
                pageLayoutMode: PdfPageLayoutMode.single,
                scrollDirection: PdfScrollDirection.horizontal,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                enableDoubleTapZooming: !isDrawingMode,
                onDocumentLoaded: _onDocumentLoaded,
                onPageChanged: _onPageChanged,
              ),
            ),

            // Drawing Canvas - ValueKey ile sayfa değişikliğini algıla
            Positioned.fill(
              child: DrawingCanvas(
                key: ValueKey('${widget.document.id}_$_currentPage'),
                documentId: widget.document.id,
                pageNumber: _currentPage,
                size: constraints.biggest,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1 ? _goToPreviousPage : null,
          ),
          GestureDetector(
            onTap: _showGoToPageDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages ? _goToNextPage : null,
          ),
        ],
      ),
    );
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
    });

    if (widget.document.currentPage > 1 &&
        widget.document.currentPage <= _totalPages) {
      _pdfController.jumpToPage(widget.document.currentPage);
    }

    _updateDocumentPageCount(details.document.pages.count);
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    final newPage = details.newPageNumber;

    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage;
      });
      _saveCurrentPage(newPage);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfController.previousPage();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _pdfController.nextPage();
    }
  }

  void _showGoToPageDialog() {
    final textController = TextEditingController(text: _currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayfaya Git'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Sayfa numarası',
            hintText: '1 - $_totalPages',
          ),
          onSubmitted: (value) {
            final page = int.tryParse(value);
            if (page != null && page >= 1 && page <= _totalPages) {
              Navigator.pop(context);
              _pdfController.jumpToPage(page);
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
              final page = int.tryParse(textController.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                Navigator.pop(context);
                _pdfController.jumpToPage(page);
              }
            },
            child: const Text('Git'),
          ),
        ],
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
