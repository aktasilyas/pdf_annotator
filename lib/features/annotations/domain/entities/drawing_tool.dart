/// Drawing Tool Enum
///
/// Kullanılabilir çizim araçlarını tanımlar.
/// Toolbar'da seçim yapılır, canvas'ta davranış buna göre değişir.
library;

enum DrawingTool {
  /// Seçim yok - pan/zoom modu
  none,

  /// Kalem - serbest çizim
  pen,

  /// Fosforlu kalem - yarı saydam işaretleme
  highlighter,

  /// Silgi - çizim silme
  eraser,
}

extension DrawingToolExtension on DrawingTool {
  /// Araç adını döner (UI için)
  String get displayName {
    switch (this) {
      case DrawingTool.none:
        return 'Seçim';
      case DrawingTool.pen:
        return 'Kalem';
      case DrawingTool.highlighter:
        return 'Fosforlu';
      case DrawingTool.eraser:
        return 'Silgi';
    }
  }

  /// Araç ikonu (Material Icons)
  String get iconName {
    switch (this) {
      case DrawingTool.none:
        return 'pan_tool';
      case DrawingTool.pen:
        return 'edit';
      case DrawingTool.highlighter:
        return 'highlight';
      case DrawingTool.eraser:
        return 'auto_fix_high';
    }
  }

  /// Çizim yapan araç mı?
  bool get isDrawingTool {
    return this == DrawingTool.pen || this == DrawingTool.highlighter;
  }
}
