/// Drawing Canvas Widget
///
/// High DPI aware drawing canvas.
/// Tek parmak: Çizim/Silgi
/// İki parmak: Zoom/Pan
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
  final VoidCallback? onTwoFingerGestureStart;
  final VoidCallback? onTwoFingerGestureEnd;

  const DrawingCanvas({
    super.key,
    required this.documentId,
    required this.pageNumber,
    required this.size,
    this.onTwoFingerGestureStart,
    this.onTwoFingerGestureEnd,
  });

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  DrawingPage? _page;
  String _currentKey = '';

  final Set<int> _activePointers = {};
  bool _isTwoFingerMode = false;
  bool _isDrawing = false;
  double _pixelRatio = 3.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pixelRatio = MediaQuery.of(context).devicePixelRatio.clamp(2.0, 4.0);
    _initPage();
  }

  @override
  void didUpdateWidget(covariant DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.documentId != widget.documentId ||
        oldWidget.pageNumber != widget.pageNumber) {
      _initPage();
    } else if (oldWidget.size != widget.size) {
      _page?.updatePageSize(widget.size, pixelRatio: _pixelRatio);
    }
  }

  void _initPage() {
    final newKey = '${widget.documentId}_${widget.pageNumber}';

    if (_currentKey == newKey && _page != null) {
      return;
    }

    _currentKey = newKey;

    final controller = ref.read(drawingControllerProvider);
    _page = controller.getOrCreatePage(
      widget.documentId,
      widget.pageNumber,
      widget.size,
      pixelRatio: _pixelRatio,
    );
    controller.setCurrentPage(
      widget.documentId,
      widget.pageNumber,
      widget.size,
      pixelRatio: _pixelRatio,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(drawingControllerProvider);
    final isInteractive = controller.selectedTool != DrawingTool.none;

    if (_page == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Listener(
        behavior: _isTwoFingerMode || !isInteractive
            ? HitTestBehavior.translucent
            : HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
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
    _activePointers.add(event.pointer);

    if (_activePointers.length >= 2) {
      _enterTwoFingerMode();
      return;
    }

    final controller = ref.read(drawingControllerProvider);
    if (controller.selectedTool == DrawingTool.none) return;

    final position = event.localPosition;

    if (controller.selectedTool.isDrawingTool) {
      controller.startDrawing(position);
      _isDrawing = true;
    } else if (controller.selectedTool == DrawingTool.eraser) {
      controller.eraseAt(position, 15.0);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isTwoFingerMode) return;

    if (_activePointers.length >= 2) {
      _enterTwoFingerMode();
      return;
    }

    final controller = ref.read(drawingControllerProvider);
    if (controller.selectedTool == DrawingTool.none) return;

    final position = event.localPosition;

    if (controller.selectedTool.isDrawingTool && _isDrawing) {
      controller.updateDrawing(position);
    } else if (controller.selectedTool == DrawingTool.eraser) {
      controller.eraseAt(position, 15.0);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      if (_isTwoFingerMode) {
        _exitTwoFingerMode();
      } else if (_isDrawing) {
        final controller = ref.read(drawingControllerProvider);
        controller.endDrawing();
        _isDrawing = false;
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      if (_isTwoFingerMode) {
        _exitTwoFingerMode();
      } else {
        final controller = ref.read(drawingControllerProvider);
        controller.cancelDrawing();
        _isDrawing = false;
      }
    }
  }

  void _enterTwoFingerMode() {
    if (_isTwoFingerMode) return;

    if (_isDrawing) {
      final controller = ref.read(drawingControllerProvider);
      controller.cancelDrawing();
      _isDrawing = false;
    }

    setState(() {
      _isTwoFingerMode = true;
    });

    widget.onTwoFingerGestureStart?.call();
  }

  void _exitTwoFingerMode() {
    if (!_isTwoFingerMode) return;

    setState(() {
      _isTwoFingerMode = false;
    });

    widget.onTwoFingerGestureEnd?.call();
  }
}
