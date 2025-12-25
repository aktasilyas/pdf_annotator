/// Drawing Page
///
/// Sayfa bazlı çizim state'i.
/// Her sayfa kendi stroke'larını, cache'ini ve undo stack'ini tutar.
library;

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/point.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

class DrawingPage extends ChangeNotifier {
  final String pageId;
  final String documentId;
  final int pageNumber;

  ui.Size _pageSize;
  ui.Size get pageSize => _pageSize;

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

  final List<_PageState> _undoStack = [];
  final List<_PageState> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  DrawingPage({
    required this.pageId,
    required this.documentId,
    required this.pageNumber,
    required ui.Size pageSize,
  }) : _pageSize = pageSize;

  void updatePageSize(ui.Size newSize) {
    if (_pageSize != newSize) {
      _pageSize = newSize;
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

  void finishStroke(Stroke finalStroke) {
    if (finalStroke.isEmpty || finalStroke.points.length < 2) {
      _activeStroke = null;
      notifyListeners();
      return;
    }

    _pushUndo();
    _strokes.add(finalStroke);
    _activeStroke = null;
    _cacheInvalid = true;
    _redoStack.clear();
    notifyListeners();
  }

  void finishHighlight(Highlight finalHighlight) {
    if (finalHighlight.isEmpty || finalHighlight.points.length < 2) {
      _activeHighlight = null;
      notifyListeners();
      return;
    }

    _pushUndo();
    _highlights.add(finalHighlight);
    _activeHighlight = null;
    _cacheInvalid = true;
    _redoStack.clear();
    notifyListeners();
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
      _pushUndo();
      _strokes.removeAt(index);
      _cacheInvalid = true;
      _redoStack.clear();
      notifyListeners();
    }
  }

  void removeHighlight(String highlightId) {
    final index = _highlights.indexWhere((h) => h.id == highlightId);
    if (index != -1) {
      _pushUndo();
      _highlights.removeAt(index);
      _cacheInvalid = true;
      _redoStack.clear();
      notifyListeners();
    }
  }

  void clear() {
    if (_strokes.isEmpty && _highlights.isEmpty) return;

    _pushUndo();
    _strokes.clear();
    _highlights.clear();
    _cacheInvalid = true;
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;

    _redoStack.add(
      _PageState(
        strokes: List.from(_strokes),
        highlights: List.from(_highlights),
      ),
    );

    final previous = _undoStack.removeLast();
    _strokes.clear();
    _strokes.addAll(previous.strokes);
    _highlights.clear();
    _highlights.addAll(previous.highlights);
    _cacheInvalid = true;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;

    _undoStack.add(
      _PageState(
        strokes: List.from(_strokes),
        highlights: List.from(_highlights),
      ),
    );

    final next = _redoStack.removeLast();
    _strokes.clear();
    _strokes.addAll(next.strokes);
    _highlights.clear();
    _highlights.addAll(next.highlights);
    _cacheInvalid = true;
    notifyListeners();
  }

  void _pushUndo() {
    _undoStack.add(
      _PageState(
        strokes: List.from(_strokes),
        highlights: List.from(_highlights),
      ),
    );
    if (_undoStack.length > 30) {
      _undoStack.removeAt(0);
    }
  }

  /// Cache'i güncelle (memory-safe)
  void updateCache(ui.Image? newCache) {
    // Önce eski cache'i dispose et
    final oldCache = _cachedBitmap;

    // Yeni cache'i ata
    _cachedBitmap = newCache;
    _cacheInvalid = false;

    // Sonra eski cache'i temizle (eğer farklıysa)
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
    // Cache'i temizle
    _cachedBitmap?.dispose();
    _cachedBitmap = null;

    // Undo/redo stack'leri temizle
    _undoStack.clear();
    _redoStack.clear();

    super.dispose();
  }
}

class _PageState {
  final List<Stroke> strokes;
  final List<Highlight> highlights;

  const _PageState({required this.strokes, required this.highlights});
}
