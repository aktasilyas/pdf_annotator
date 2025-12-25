/// Drawing Canvas Widget
///
/// Listener pattern ile yüksek performanslı çizim canvas'ı.
/// setState kullanmaz, doğrudan page'e notify eder.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_tool.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';
import 'package:pdf_annotator/features/annotations/presentation/providers/drawing_provider.dart';
import 'package:pdf_annotator/features/annotations/presentation/painters/stroke_painter.dart';

class DrawingCanvas extends ConsumerStatefulWidget {
  final String documentId;
  final int pageNumber;
  final Size size;

  const DrawingCanvas({
    super.key,
    required this.documentId,
    required this.pageNumber,
    required this.size,
  });

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  DrawingPage? _page;
  String _currentKey = '';

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  @override
  void didUpdateWidget(covariant DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sayfa veya doküman değiştiyse yeniden init
    if (oldWidget.documentId != widget.documentId ||
        oldWidget.pageNumber != widget.pageNumber) {
      _initPage();
    } else if (oldWidget.size != widget.size) {
      // Sadece boyut değiştiyse güncelle
      _page?.updatePageSize(widget.size);
    }
  }

  void _initPage() {
    final newKey = '${widget.documentId}_${widget.pageNumber}';

    // Aynı sayfa zaten yüklüyse tekrar init yapma
    if (_currentKey == newKey && _page != null) {
      return;
    }

    _currentKey = newKey;

    final controller = ref.read(drawingControllerProvider);
    _page = controller.getOrCreatePage(
      widget.documentId,
      widget.pageNumber,
      widget.size,
    );
    controller.setCurrentPage(
      widget.documentId,
      widget.pageNumber,
      widget.size,
    );

    // Widget'ı yeniden çiz
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(drawingControllerProvider);
    final isInteractive = controller.selectedTool != DrawingTool.none;

    // Page henüz yüklenmediyse boş göster
    if (_page == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Listener(
        behavior: isInteractive
            ? HitTestBehavior.opaque
            : HitTestBehavior.translucent,
        onPointerDown: isInteractive ? _onPointerDown : null,
        onPointerMove: isInteractive ? _onPointerMove : null,
        onPointerUp: isInteractive ? _onPointerUp : null,
        onPointerCancel: isInteractive ? _onPointerCancel : null,
        child: AnimatedBuilder(
          animation: _page!,
          builder: (context, _) {
            return CustomPaint(
              size: widget.size,
              isComplex: true,
              willChange:
                  _page!.activeStroke != null || _page!.activeHighlight != null,
              painter: StrokePainter(page: _page!),
            );
          },
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    final controller = ref.read(drawingControllerProvider);
    final position = event.localPosition;

    if (controller.selectedTool.isDrawingTool) {
      controller.startDrawing(position);
    } else if (controller.selectedTool == DrawingTool.eraser) {
      controller.eraseAt(position, 15.0);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final controller = ref.read(drawingControllerProvider);
    final position = event.localPosition;

    if (controller.selectedTool.isDrawingTool) {
      controller.updateDrawing(position);
    } else if (controller.selectedTool == DrawingTool.eraser) {
      controller.eraseAt(position, 15.0);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    final controller = ref.read(drawingControllerProvider);
    controller.endDrawing();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    final controller = ref.read(drawingControllerProvider);
    controller.cancelDrawing();
  }
}
