/// Application Constants
///
/// Tüm hard-coded değerler bu dosyada merkezi olarak yönetilir.
/// Magic number'ları önlemek ve bakımı kolaylaştırmak için kullanılır.
library;

/// Drawing ve Canvas sabitleri
class DrawingConstants {
  DrawingConstants._();

  // =========================================================================
  // Pixel Ratio & Quality
  // =========================================================================

  /// Minimum pixel ratio (low-end devices)
  static const double minPixelRatio = 1.5;

  /// Default pixel ratio (balance between quality and memory)
  static const double defaultPixelRatio = 2.0;

  /// Maximum pixel ratio (high-end devices)
  static const double maxPixelRatio = 3.0;

  /// Cache rebuild için minimum pixel ratio
  static const double cacheRebuildMinPixelRatio = 2.0;

  // =========================================================================
  // Stroke & Point Processing
  // =========================================================================

  /// Point thinning için minimum mesafe (pixel)
  static const double pointThinningMinDistance = 2.0;

  /// Point thinning için minimum zaman farkı (ms)
  static const int pointThinningMinTimeDelta = 8;

  /// Eraser tolerance (pixel)
  static const double eraserTolerance = 15.0;

  /// Minimum stroke point sayısı (valid stroke için)
  static const int minStrokePoints = 2;

  // =========================================================================
  // Default Tool Settings
  // =========================================================================

  /// Default pen stroke width
  static const double defaultPenWidth = 3.0;

  /// Minimum pen width
  static const double minPenWidth = 1.0;

  /// Maximum pen width
  static const double maxPenWidth = 10.0;

  /// Default highlighter width
  static const double defaultHighlighterWidth = 20.0;

  /// Minimum highlighter width
  static const double minHighlighterWidth = 10.0;

  /// Maximum highlighter width
  static const double maxHighlighterWidth = 40.0;

  /// Default highlighter opacity
  static const double defaultHighlighterOpacity = 0.4;

  /// Default pen opacity
  static const double defaultPenOpacity = 1.0;

  // =========================================================================
  // Undo/Redo
  // =========================================================================

  /// Maximum undo stack size
  static const int maxUndoStackSize = 30;

  /// Maximum redo stack size
  static const int maxRedoStackSize = 30;
}

/// PDF Viewer sabitleri
class ViewerConstants {
  ViewerConstants._();

  /// Minimum zoom level
  static const double minScale = 0.5;

  /// Maximum zoom level
  static const double maxScale = 4.0;

  /// Default zoom level
  static const double defaultScale = 1.0;

  /// Double tap zoom level
  static const double doubleTapZoomScale = 2.0;
}

/// UI sabitleri
class UIConstants {
  UIConstants._();

  // =========================================================================
  // Toolbar Positioning
  // =========================================================================

  /// Floating toolbar padding from left (landscape)
  static const double toolbarPaddingLeftLandscape = 300.0;

  /// Floating toolbar padding from left (portrait)
  static const double toolbarPaddingLeftPortrait = 200.0;

  /// Floating toolbar padding from right
  static const double toolbarPaddingRight = 16.0;

  /// Floating toolbar padding from bottom
  static const double toolbarPaddingBottom = 16.0;

  // =========================================================================
  // Animation Durations
  // =========================================================================

  /// Quick animation duration
  static const Duration quickAnimation = Duration(milliseconds: 200);

  /// Normal animation duration
  static const Duration normalAnimation = Duration(milliseconds: 300);

  /// Slow animation duration
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // =========================================================================
  // Grid & Spacing
  // =========================================================================

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Small padding
  static const double smallPadding = 8.0;

  /// Large padding
  static const double largePadding = 24.0;

  /// Default border radius
  static const double defaultBorderRadius = 12.0;
}

/// Database sabitleri
class DatabaseConstants {
  DatabaseConstants._();

  /// Database adı
  static const String databaseName = 'pdf_annotator.db';

  /// Database versiyonu
  static const int databaseVersion = 1;

  /// Documents table adı
  static const String documentsTable = 'documents';

  /// Annotations table adı
  static const String annotationsTable = 'annotations';

  // =========================================================================
  // Query Limits
  // =========================================================================

  /// Default pagination limit
  static const int defaultPaginationLimit = 50;

  /// Maximum batch insert size
  static const int maxBatchInsertSize = 100;

  // =========================================================================
  // Timeouts
  // =========================================================================

  /// Database query timeout
  static const Duration queryTimeout = Duration(seconds: 30);

  /// Database transaction timeout
  static const Duration transactionTimeout = Duration(seconds: 60);
}

/// Cache sabitleri
class CacheConstants {
  CacheConstants._();

  /// Maximum cache'de tutulacak sayfa sayısı (LRU)
  static const int maxCachedPages = 10;

  /// Cache temizleme threshold (MB)
  static const int cacheSizeThresholdMB = 100;

  /// Bitmap cache rebuild debounce duration
  static const Duration cacheRebuildDebounce = Duration(milliseconds: 100);
}

/// Validation sabitleri
class ValidationConstants {
  ValidationConstants._();

  /// Minimum document title length
  static const int minTitleLength = 1;

  /// Maximum document title length
  static const int maxTitleLength = 255;

  /// Maximum file size (MB) - 100MB
  static const int maxFileSizeMB = 100;

  /// Maximum file size (bytes)
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

  /// Allowed file extensions
  static const List<String> allowedFileExtensions = ['.pdf'];

  /// Minimum page number
  static const int minPageNumber = 0;
}

/// Error Messages
class ErrorMessages {
  ErrorMessages._();

  // =========================================================================
  // Database Errors
  // =========================================================================

  static const String databaseNotInitialized =
      'Veritabanı başlatılmamış. Lütfen uygulamayı yeniden başlatın.';

  static const String databaseQueryFailed =
      'Veritabanı sorgusu başarısız oldu. Lütfen tekrar deneyin.';

  static const String databaseInsertFailed =
      'Veri kaydedilemedi. Lütfen tekrar deneyin.';

  // =========================================================================
  // File Errors
  // =========================================================================

  static const String fileNotFound = 'Dosya bulunamadı.';

  static const String fileTooBig =
      'Dosya çok büyük. Maksimum ${ValidationConstants.maxFileSizeMB}MB desteklenmektedir.';

  static const String invalidFileFormat =
      'Geçersiz dosya formatı. Sadece PDF dosyaları desteklenmektedir.';

  // =========================================================================
  // Validation Errors
  // =========================================================================

  static const String titleTooShort =
      'Başlık en az ${ValidationConstants.minTitleLength} karakter olmalıdır.';

  static const String titleTooLong =
      'Başlık en fazla ${ValidationConstants.maxTitleLength} karakter olabilir.';

  static const String invalidPageNumber = 'Geçersiz sayfa numarası.';

  // =========================================================================
  // JSON Errors
  // =========================================================================

  static const String jsonDecodeFailed =
      'Veri yapısı bozuk. Annotation yüklenemedi.';

  static const String jsonMissingField = 'Eksik veri alanı tespit edildi.';
}

/// Color Palette
class ColorPalette {
  ColorPalette._();

  /// Drawing tool colors (ARGB format)
  static const List<int> defaultColors = [
    0xFF000000, // Black
    0xFFFF0000, // Red
    0xFF0000FF, // Blue
    0xFF00FF00, // Green
    0xFFFFFF00, // Yellow
    0xFFFF00FF, // Magenta
    0xFF00FFFF, // Cyan
    0xFFFF8800, // Orange
    0xFF8800FF, // Purple
  ];

  /// Highlighter colors (ARGB format) - more transparent
  static const List<int> highlighterColors = [
    0x66FFFF00, // Yellow (transparent)
    0x6600FF00, // Green (transparent)
    0x66FF00FF, // Magenta (transparent)
    0x6600FFFF, // Cyan (transparent)
    0x66FF8800, // Orange (transparent)
  ];
}
