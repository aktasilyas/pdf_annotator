/// Drawing Provider
///
/// Sayfa bazlı çizim yönetimi.
/// Her sayfa için DrawingPage instance'ı tutar.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf_annotator/core/utils/logger.dart';
import 'package:pdf_annotator/core/utils/point_thinner.dart';
import 'package:pdf_annotator/core/utils/stroke_smoother.dart';
import 'package:pdf_annotator/core/utils/lru_cache.dart';
import 'package:pdf_annotator/core/constants/app_constants.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_tool.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/annotation_type.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_page.dart';
import 'package:pdf_annotator/features/annotations/presentation/painters/bitmap_cache_manager.dart';
import 'package:pdf_annotator/features/annotations/data/datasources/annotation_local_datasource.dart';
import 'package:pdf_annotator/features/annotations/data/repositories/annotation_repository_impl.dart';
import 'package:pdf_annotator/features/annotations/domain/repositories/annotation_repository.dart';

// =============================================================================
// Providers
// =============================================================================

final annotationLocalDatasourceProvider = Provider<AnnotationLocalDatasource>((
  ref,
) {
  return AnnotationLocalDatasource();
});

final annotationRepositoryProvider = Provider<AnnotationRepository>((ref) {
  final datasource = ref.watch(annotationLocalDatasourceProvider);
  return AnnotationRepositoryImpl(datasource);
});

final drawingControllerProvider = ChangeNotifierProvider<DrawingController>((
  ref,
) {
  final repository = ref.watch(annotationRepositoryProvider);
  return DrawingController(repository);
});

// =============================================================================
// Drawing Controller
// =============================================================================

class DrawingController extends ChangeNotifier {
  final AnnotationRepository _repository;

  // LRU cache - en fazla CacheConstants.maxCachedPages sayfa tutar
  final LRUCache<String, DrawingPage> _pages = LRUCache(
    CacheConstants.maxCachedPages,
  );

  String? _currentPageKey;
  DrawingPage? get currentPage =>
      _currentPageKey != null ? _pages.get(_currentPageKey!) : null;

  DrawingTool _selectedTool = DrawingTool.none;
  DrawingTool get selectedTool => _selectedTool;

  Color _selectedColor = Colors.black;
  Color get selectedColor => _selectedColor;

  double _strokeWidth = DrawingConstants.defaultPenWidth;
  double get strokeWidth => _strokeWidth;

  double _highlightWidth = DrawingConstants.defaultHighlighterWidth;
  double get highlightWidth => _highlightWidth;

  final _uuid = const Uuid();
  final _pointThinner = const PointThinner();
  final _strokeSmoother = const StrokeSmoother();
  final _cacheManager = const BitmapCacheManager();

  Point? _lastPoint;

  /// İşlem devam ediyor mu? (çakışmayı önle)
  bool _isProcessing = false;

  DrawingController(this._repository);

  // ===========================================================================
  // Page Management
  // ===========================================================================

  /// Sayfa al veya oluştur (LRU cache ile)
  DrawingPage getOrCreatePage(
    String documentId,
    int pageNumber,
    Size size, {
    double? pixelRatio,
  }) {
    final key = '${documentId}_$pageNumber';
    final effectivePixelRatio =
        pixelRatio ?? DrawingConstants.defaultPixelRatio;

    // LRU cache'den kontrol et
    final existingPage = _pages.get(key);
    if (existingPage != null) {
      existingPage.updatePageSize(size, pixelRatio: effectivePixelRatio);
      return existingPage;
    }

    // Yeni sayfa oluştur
    final newPage = DrawingPage(
      pageId: key,
      documentId: documentId,
      pageNumber: pageNumber,
      pageSize: size,
      pixelRatio: effectivePixelRatio,
    );

    // LRU cache'e ekle (otomatik olarak eski sayfaları temizler)
    _pages.put(key, newPage);

    // Annotations yükle
    _loadPageAnnotations(documentId, pageNumber, newPage);

    logger.debug(
      'Created page $key (cache size: ${_pages.size}/${_pages.maxSize})',
    );

    return newPage;
  }

  void setCurrentPage(
    String documentId,
    int pageNumber,
    Size size, {
    double? pixelRatio,
  }) {
    final key = '${documentId}_$pageNumber';

    if (_currentPageKey == key) {
      return;
    }

    currentPage?.cancelDrawing();

    _currentPageKey = key;
    _lastPoint = null;

    final page = getOrCreatePage(
      documentId,
      pageNumber,
      size,
      pixelRatio: pixelRatio,
    );

    if (page.needsCacheRebuild &&
        (page.strokes.isNotEmpty || page.highlights.isNotEmpty)) {
      _rebuildCacheAsync(page);
    }

    notifyListeners();
  }

  Future<void> _loadPageAnnotations(
    String documentId,
    int pageNumber,
    DrawingPage page,
  ) async {
    try {
      final strokes = await _repository.getStrokesByPage(
        documentId,
        pageNumber,
      );
      final highlights = await _repository.getHighlightsByPage(
        documentId,
        pageNumber,
      );

      page.loadAnnotations(strokes, highlights);

      if (strokes.isNotEmpty || highlights.isNotEmpty) {
        await _rebuildCacheAsync(page);
      }

      logger.debug(
        'Loaded ${strokes.length} strokes, ${highlights.length} highlights for page $pageNumber',
      );
    } catch (e, st) {
      logger.error('Failed to load annotations', error: e, stackTrace: st);
    }
  }

  // ===========================================================================
  // Tool Settings
  // ===========================================================================

  void selectTool(DrawingTool tool) {
    if (_selectedTool != tool) {
      _selectedTool = tool;
      notifyListeners();
    }
  }

  void selectColor(Color color) {
    if (_selectedColor != color) {
      _selectedColor = color;
      notifyListeners();
    }
  }

  void setStrokeWidth(double width) {
    final clampedWidth = width.clamp(
      DrawingConstants.minPenWidth,
      DrawingConstants.maxPenWidth,
    );
    if (_strokeWidth != clampedWidth) {
      _strokeWidth = clampedWidth;
      notifyListeners();
    }
  }

  void setHighlightWidth(double width) {
    final clampedWidth = width.clamp(
      DrawingConstants.minHighlighterWidth,
      DrawingConstants.maxHighlighterWidth,
    );
    if (_highlightWidth != clampedWidth) {
      _highlightWidth = clampedWidth;
      notifyListeners();
    }
  }

  // ===========================================================================
  // Drawing Operations
  // ===========================================================================

  void startDrawing(Offset position) {
    final page = currentPage;
    if (page == null || !_selectedTool.isDrawingTool) return;

    final point = Point(
      x: position.dx,
      y: position.dy,
      pressure: 1.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _lastPoint = point;
    final now = DateTime.now();

    if (_selectedTool == DrawingTool.pen) {
      final stroke = Stroke(
        id: _uuid.v4(),
        documentId: page.documentId,
        pageNumber: page.pageNumber,
        type: AnnotationType.stroke,
        color: _selectedColor.value.toInt(), // Use toInt() instead of deprecated .value
        strokeWidth: _strokeWidth,
        opacity: DrawingConstants.defaultPenOpacity,
        points: [point],
        createdAt: now,
        updatedAt: now,
        zIndex: page.strokes.length + page.highlights.length,
      );
      page.startStroke(stroke);
    } else if (_selectedTool == DrawingTool.highlighter) {
      final highlight = Highlight(
        id: _uuid.v4(),
        documentId: page.documentId,
        pageNumber: page.pageNumber,
        type: AnnotationType.highlight,
        color: _selectedColor.value.toInt(), // Use toInt() instead of deprecated .value
        strokeWidth: _highlightWidth,
        opacity: DrawingConstants.defaultHighlighterOpacity,
        points: [point],
        createdAt: now,
        updatedAt: now,
        zIndex: page.strokes.length + page.highlights.length,
      );
      page.startHighlight(highlight);
    }
  }

  void updateDrawing(Offset position) {
    final page = currentPage;
    if (page == null) return;

    final point = Point(
      x: position.dx,
      y: position.dy,
      pressure: 1.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    if (!_pointThinner.shouldAddPoint(_lastPoint, point)) {
      return;
    }

    _lastPoint = point;

    if (page.activeStroke != null) {
      page.addPointToStroke(point);
    } else if (page.activeHighlight != null) {
      page.addPointToHighlight(point);
    }
  }

  /// Çizimi bitir
  /// Çizimi bitir - NO SMOOTHING (path builder handles it)
  Future<void> endDrawing() async {
    final page = currentPage;
    if (page == null) return;

    if (_isProcessing) return;
    _isProcessing = true;

    _lastPoint = null;

    try {
      if (page.activeStroke != null) {
        final activeStroke = page.activeStroke!;

        if (activeStroke.points.length < 2) {
          page.cancelDrawing();
          return;
        }

        // Finish stroke without notifying (keep it visible during cache update)
        page.finishStroke(activeStroke, notify: false);

        // Update cache with high DPI (async)
        final newCache = await _cacheManager.appendStroke(
          page,
          page.cachedBitmap,
          activeStroke,
        );

        // Update cache - this will notify listeners once
        page.updateCache(newCache);

        // Save to DB (fire and forget)
        _saveStroke(activeStroke);
      }

      if (page.activeHighlight != null) {
        final activeHighlight = page.activeHighlight!;

        if (activeHighlight.points.length < 2) {
          page.cancelDrawing();
          return;
        }

        // Finish highlight without notifying (keep it visible during cache update)
        page.finishHighlight(activeHighlight, notify: false);

        // Rebuild cache for proper blending (async)
        final newCache = await _cacheManager.appendHighlight(
          page,
          page.cachedBitmap,
          activeHighlight,
        );

        // Update cache - this will notify listeners once
        page.updateCache(newCache);

        // Save to DB (fire and forget)
        _saveHighlight(activeHighlight);
      }
    } finally {
      _isProcessing = false;
    }
  }

  void cancelDrawing() {
    currentPage?.cancelDrawing();
    _lastPoint = null;
  }

  // ===========================================================================
  // Eraser
  // ===========================================================================

  Future<void> eraseAt(Offset position, double tolerance) async {
    final page = currentPage;
    if (page == null || _selectedTool != DrawingTool.eraser) return;

    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final stroke = page.findStrokeAt(position, tolerance);
      if (stroke != null) {
        page.removeStroke(stroke.id);
        await _rebuildCacheAsync(page);
        _repository.deleteAnnotation(stroke.id);
        logger.debug('Erased stroke: ${stroke.id}');
        return;
      }

      final highlight = page.findHighlightAt(position, tolerance);
      if (highlight != null) {
        page.removeHighlight(highlight.id);
        await _rebuildCacheAsync(page);
        _repository.deleteAnnotation(highlight.id);
        logger.debug('Erased highlight: ${highlight.id}');
      }
    } finally {
      _isProcessing = false;
    }
  }

  // ===========================================================================
  // Undo / Redo
  // ===========================================================================

  bool get canUndo => currentPage?.canUndo ?? false;
  bool get canRedo => currentPage?.canRedo ?? false;

  Future<void> undo() async {
    final page = currentPage;
    if (page == null || !page.canUndo) return;

    if (_isProcessing) return;
    _isProcessing = true;

    try {
      page.undo();
      await _rebuildCacheAsync(page);
      logger.debug('Undo performed');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> redo() async {
    final page = currentPage;
    if (page == null || !page.canRedo) return;

    if (_isProcessing) return;
    _isProcessing = true;

    try {
      page.redo();
      await _rebuildCacheAsync(page);
      logger.debug('Redo performed');
    } finally {
      _isProcessing = false;
    }
  }

  // ===========================================================================
  // Clear
  // ===========================================================================

  Future<void> clearCurrentPage() async {
    final page = currentPage;
    if (page == null) return;

    if (_isProcessing) return;
    _isProcessing = true;

    try {
      page.clear();
      page.updateCache(null);

      await _repository.deleteAnnotationsByPage(
        page.documentId,
        page.pageNumber,
      );
      logger.info('Cleared page ${page.pageNumber}');
    } finally {
      _isProcessing = false;
    }
  }

  // ===========================================================================
  // Cache Management
  // ===========================================================================

  Future<void> _rebuildCacheAsync(DrawingPage page) async {
    final newCache = await _cacheManager.rebuildCache(page);
    page.updateCache(newCache);
  }
  // ===========================================================================
  // DB Operations
  // ===========================================================================

  Future<void> _saveStroke(Stroke stroke) async {
    try {
      await _repository.insertStroke(stroke);
      logger.debug('Stroke saved: ${stroke.id}');
    } catch (e, st) {
      logger.error('Failed to save stroke', error: e, stackTrace: st);
    }
  }

  Future<void> _saveHighlight(Highlight highlight) async {
    try {
      await _repository.insertHighlight(highlight);
      logger.debug('Highlight saved: ${highlight.id}');
    } catch (e, st) {
      logger.error('Failed to save highlight', error: e, stackTrace: st);
    }
  }

  // ===========================================================================
  // Dispose
  // ===========================================================================

  /// Cache size bilgisi al
  int get cacheSize => _pages.size;
  int get maxCacheSize => _pages.maxSize;

  /// Manual cache temizliği (gerekirse)
  void clearCache() {
    final currentKey = _currentPageKey;
    _pages.clear();
    _currentPageKey = null;
    logger.info('Cache cleared, current page was: $currentKey');
    notifyListeners();
  }

  @override
  void dispose() {
    _pages.clear();
    super.dispose();
  }
}
