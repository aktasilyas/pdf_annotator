/// Drawing Page
///
/// Sayfa bazlı çizim state'i.
/// Her sayfa kendi stroke'larını, cache'ini ve undo stack'ini tutar.
/// High DPI desteği ile yüksek kaliteli render.
/// Differential undo/redo sistemi ile düşük memory footprint.
library;

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/undo_operation.dart';
import 'package:pdf_annotator/core/constants/app_constants.dart';

class DrawingPage extends ChangeNotifier implements UndoablePageState {
  final String pageId;
  final String documentId;
  final int pageNumber;

  ui.Size _pageSize;
  ui.Size get pageSize => _pageSize;

  /// Device pixel ratio for high DPI rendering
  double _pixelRatio;
  double get pixelRatio => _pixelRatio;

  final List<Stroke> _strokes = [];
  List<Stroke> get strokes => List.unmodifiable(_strokes);

  final List<Highlight> _highlights = [];
  List<Highlight> get highlights => List.unmodifiable(_highlights);

  Stroke? _activeStroke;
  Stroke? get activeStroke => _activeStroke;

  Highlight? _activeHighlight;
  Highlight? get activeHighlight => _activeHighlight;

  ui.Image? _cachedBitmap;
  ui.Image? get cachedBitmap => _cachedBitmap;

  bool _cacheInvalid = true;
  bool get needsCacheRebuild => _cacheInvalid;

  // Differential undo/redo - sadece operasyonları tutar, full state değil
  final List<UndoOperation> _undoStack = [];
  final List<UndoOperation> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  DrawingPage({
    required this.pageId,
    required this.documentId,
    required this.pageNumber,
    required ui.Size pageSize,
    double pixelRatio = 2.0, // Optimized default (balance between quality and performance)
  })  : _pageSize = pageSize,
        _pixelRatio = pixelRatio.clamp(
          DrawingConstants.minPixelRatio,
          DrawingConstants.maxPixelRatio,
        );

  void updatePageSize(ui.Size newSize, {double? pixelRatio}) {
    bool changed = false;

    if (_pageSize != newSize) {
      _pageSize = newSize;
      changed = true;
    }

    if (pixelRatio != null && _pixelRatio != pixelRatio) {
      _pixelRatio = pixelRatio;
      changed = true;
    }

    if (changed) {
      _cacheInvalid = true;
      notifyListeners();
    }
  }

  void loadAnnotations(List<Stroke> strokes, List<Highlight> highlights) {
    _strokes.clear();
    _strokes.addAll(strokes);
    _highlights.clear();
    _highlights.addAll(highlights);
    _cacheInvalid = true;
    notifyListeners();
  }

  void startStroke(Stroke stroke) {
    _activeStroke = stroke;
    notifyListeners();
  }

  void startHighlight(Highlight highlight) {
    _activeHighlight = highlight;
    notifyListeners();
  }

  void addPointToStroke(Point point) {
    if (_activeStroke == null) return;
    _activeStroke = _activeStroke!.addPoint(point);
    notifyListeners();
  }

  void addPointToHighlight(Point point) {
    if (_activeHighlight == null) return;
    _activeHighlight = _activeHighlight!.addPoint(point);
    notifyListeners();
  }

  void finishStroke(Stroke finalStroke, {bool notify = true}) {
    if (finalStroke.isEmpty ||
        finalStroke.points.length < DrawingConstants.minStrokePoints) {
      _activeStroke = null;
      if (notify) notifyListeners();
      return;
    }

    // Differential undo - sadece ekleme operasyonunu kaydet
    _pushUndoOperation(AddStrokeOperation(finalStroke));
    _strokes.add(finalStroke);
    _activeStroke = null;
    _cacheInvalid = true;
    _redoStack.clear();
    if (notify) notifyListeners();
  }

  void finishHighlight(Highlight finalHighlight, {bool notify = true}) {
    if (finalHighlight.isEmpty ||
        finalHighlight.points.length < DrawingConstants.minStrokePoints) {
      _activeHighlight = null;
      if (notify) notifyListeners();
      return;
    }

    // Differential undo - sadece ekleme operasyonunu kaydet
    _pushUndoOperation(AddHighlightOperation(finalHighlight));
    _highlights.add(finalHighlight);
    _activeHighlight = null;
    _cacheInvalid = true;
    _redoStack.clear();
    if (notify) notifyListeners();
  }

  void cancelDrawing() {
    if (_activeStroke != null || _activeHighlight != null) {
      _activeStroke = null;
      _activeHighlight = null;
      notifyListeners();
    }
  }

  void removeStroke(String strokeId) {
    final index = _strokes.indexWhere((s) => s.id == strokeId);
    if (index != -1) {
      final stroke = _strokes[index];
      // Differential undo - silinen stroke'u ve pozisyonunu kaydet
      _pushUndoOperation(RemoveStrokeOperation(stroke, index));
      _strokes.removeAt(index);
      _cacheInvalid = true;
      _redoStack.clear();
      notifyListeners();
    }
  }

  void removeHighlight(String highlightId) {
    final index = _highlights.indexWhere((h) => h.id == highlightId);
    if (index != -1) {
      final highlight = _highlights[index];
      // Differential undo - silinen highlight'ı ve pozisyonunu kaydet
      _pushUndoOperation(RemoveHighlightOperation(highlight, index));
      _highlights.removeAt(index);
      _cacheInvalid = true;
      _redoStack.clear();
      notifyListeners();
    }
  }

  void clear() {
    if (_strokes.isEmpty && _highlights.isEmpty) return;

    // Differential undo - tüm annotations'ı kaydet
    _pushUndoOperation(
      ClearAllOperation(List.from(_strokes), List.from(_highlights)),
    );
    _strokes.clear();
    _highlights.clear();
    _cacheInvalid = true;
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;

    final operation = _undoStack.removeLast();
    operation.undo(this);

    _redoStack.add(operation);
    if (_redoStack.length > DrawingConstants.maxRedoStackSize) {
      _redoStack.removeAt(0);
    }

    _cacheInvalid = true;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;

    final operation = _redoStack.removeLast();
    operation.redo(this);

    _undoStack.add(operation);
    if (_undoStack.length > DrawingConstants.maxUndoStackSize) {
      _undoStack.removeAt(0);
    }

    _cacheInvalid = true;
    notifyListeners();
  }

  void _pushUndoOperation(UndoOperation operation) {
    _undoStack.add(operation);
    if (_undoStack.length > DrawingConstants.maxUndoStackSize) {
      _undoStack.removeAt(0);
    }
  }

  // UndoablePageState implementation
  @override
  void addStroke(Stroke stroke) {
    _strokes.add(stroke);
  }

  @override
  void removeStrokeById(String id) {
    _strokes.removeWhere((s) => s.id == id);
  }

  @override
  void insertStrokeAt(int index, Stroke stroke) {
    _strokes.insert(index, stroke);
  }

  @override
  void restoreStrokes(List<Stroke> strokes) {
    _strokes.clear();
    _strokes.addAll(strokes);
  }

  @override
  void addHighlight(Highlight highlight) {
    _highlights.add(highlight);
  }

  @override
  void removeHighlightById(String id) {
    _highlights.removeWhere((h) => h.id == id);
  }

  @override
  void insertHighlightAt(int index, Highlight highlight) {
    _highlights.insert(index, highlight);
  }

  @override
  void restoreHighlights(List<Highlight> highlights) {
    _highlights.clear();
    _highlights.addAll(highlights);
  }

  @override
  void clearAll() {
    _strokes.clear();
    _highlights.clear();
  }

  void updateCache(ui.Image? newCache) {
    final oldCache = _cachedBitmap;
    _cachedBitmap = newCache;
    _cacheInvalid = false;

    // Dispose old cache after setting new one
    if (oldCache != null && oldCache != newCache) {
      oldCache.dispose();
    }

    notifyListeners();
  }

  void invalidateCache() {
    _cacheInvalid = true;
  }

  Stroke? findStrokeAt(ui.Offset position, double tolerance) {
    for (int i = _strokes.length - 1; i >= 0; i--) {
      final stroke = _strokes[i];
      for (final point in stroke.points) {
        final dx = point.x - position.dx;
        final dy = point.y - position.dy;
        final distSq = dx * dx + dy * dy;
        final threshold = tolerance + stroke.strokeWidth / 2;
        if (distSq <= threshold * threshold) {
          return stroke;
        }
      }
    }
    return null;
  }

  Highlight? findHighlightAt(ui.Offset position, double tolerance) {
    for (int i = _highlights.length - 1; i >= 0; i--) {
      final highlight = _highlights[i];
      for (final point in highlight.points) {
        final dx = point.x - position.dx;
        final dy = point.y - position.dy;
        final distSq = dx * dx + dy * dy;
        final threshold = tolerance + highlight.strokeWidth / 2;
        if (distSq <= threshold * threshold) {
          return highlight;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _cachedBitmap?.dispose();
    _cachedBitmap = null;
    _undoStack.clear();
    _redoStack.clear();
    super.dispose();
  }
}
