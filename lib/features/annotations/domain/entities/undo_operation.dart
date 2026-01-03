/// Undo/Redo Operations
///
/// Differential undo/redo sistemi için operasyon tipleri.
/// Full state copy yerine sadece değişiklikleri tutar.
/// Bu sayede memory footprint drastik olarak azalır.
library;

import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

/// Base Undo Operation
abstract class UndoOperation {
  const UndoOperation();

  /// Operasyonu geri al
  void undo(UndoablePageState state);

  /// Operasyonu yeniden uygula
  void redo(UndoablePageState state);
}

/// Stroke ekleme operasyonu
class AddStrokeOperation extends UndoOperation {
  final Stroke stroke;

  const AddStrokeOperation(this.stroke);

  @override
  void undo(UndoablePageState state) {
    state.removeStrokeById(stroke.id);
  }

  @override
  void redo(UndoablePageState state) {
    state.addStroke(stroke);
  }
}

/// Stroke silme operasyonu
class RemoveStrokeOperation extends UndoOperation {
  final Stroke stroke;
  final int originalIndex;

  const RemoveStrokeOperation(this.stroke, this.originalIndex);

  @override
  void undo(UndoablePageState state) {
    state.insertStrokeAt(originalIndex, stroke);
  }

  @override
  void redo(UndoablePageState state) {
    state.removeStrokeById(stroke.id);
  }
}

/// Highlight ekleme operasyonu
class AddHighlightOperation extends UndoOperation {
  final Highlight highlight;

  const AddHighlightOperation(this.highlight);

  @override
  void undo(UndoablePageState state) {
    state.removeHighlightById(highlight.id);
  }

  @override
  void redo(UndoablePageState state) {
    state.addHighlight(highlight);
  }
}

/// Highlight silme operasyonu
class RemoveHighlightOperation extends UndoOperation {
  final Highlight highlight;
  final int originalIndex;

  const RemoveHighlightOperation(this.highlight, this.originalIndex);

  @override
  void undo(UndoablePageState state) {
    state.insertHighlightAt(originalIndex, highlight);
  }

  @override
  void redo(UndoablePageState state) {
    state.removeHighlightById(highlight.id);
  }
}

/// Tüm annotation'ları temizleme operasyonu
class ClearAllOperation extends UndoOperation {
  final List<Stroke> strokes;
  final List<Highlight> highlights;

  const ClearAllOperation(this.strokes, this.highlights);

  @override
  void undo(UndoablePageState state) {
    state.restoreStrokes(strokes);
    state.restoreHighlights(highlights);
  }

  @override
  void redo(UndoablePageState state) {
    state.clearAll();
  }
}

/// Batch operation - birden fazla operasyonu gruplar
class BatchOperation extends UndoOperation {
  final List<UndoOperation> operations;

  const BatchOperation(this.operations);

  @override
  void undo(UndoablePageState state) {
    // Reverse order for undo
    for (var i = operations.length - 1; i >= 0; i--) {
      operations[i].undo(state);
    }
  }

  @override
  void redo(UndoablePageState state) {
    // Forward order for redo
    for (final operation in operations) {
      operation.redo(state);
    }
  }
}

/// Undo/Redo yapılabilir page state interface
abstract class UndoablePageState {
  void addStroke(Stroke stroke);
  void removeStrokeById(String id);
  void insertStrokeAt(int index, Stroke stroke);
  void restoreStrokes(List<Stroke> strokes);

  void addHighlight(Highlight highlight);
  void removeHighlightById(String id);
  void insertHighlightAt(int index, Highlight highlight);
  void restoreHighlights(List<Highlight> highlights);

  void clearAll();
}
