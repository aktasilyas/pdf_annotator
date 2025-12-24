/// Logger Service
///
/// Uygulama genelinde loglama işlemlerini yönetir.
/// Singleton pattern ile tek instance kullanılır.
///
/// Log seviyeleri:
/// - debug: Geliştirme aşamasında detaylı bilgi
/// - info: Genel bilgi mesajları
/// - warning: Uyarılar (hata değil ama dikkat edilmeli)
/// - error: Hatalar (stack trace ile)
///
/// Kullanım:
/// ```dart
/// final logger = AppLogger();
/// logger.debug('User tapped button');
/// logger.info('Document imported: ${doc.title}');
/// logger.warning('Large file detected', details: {'size': fileSize});
/// logger.error('Failed to save', error: e, stackTrace: st);
/// ```
library;

import 'package:flutter/foundation.dart';

/// Log seviyeleri
enum LogLevel { debug, info, warning, error }

/// Log entry model
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? details;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.details,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}]');
    buffer.write(' [${level.name.toUpperCase()}]');
    buffer.write(' $message');

    if (details != null && details!.isNotEmpty) {
      buffer.write(' | $details');
    }

    return buffer.toString();
  }
}

/// Application Logger
///
/// Singleton logger servisi
class AppLogger {
  /// Singleton instance
  static final AppLogger _instance = AppLogger._internal();

  /// Factory constructor - her zaman aynı instance'ı döner
  factory AppLogger() => _instance;

  /// Private constructor
  AppLogger._internal();

  /// Minimum log seviyesi (bu seviyenin altındakiler loglanmaz)
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Log geçmişi (son 100 log)
  final List<LogEntry> _history = [];

  /// Maksimum history boyutu
  static const int _maxHistorySize = 100;

  /// Minimum log seviyesini ayarla
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Log geçmişini getir
  List<LogEntry> get history => List.unmodifiable(_history);

  /// Log geçmişini temizle
  void clearHistory() {
    _history.clear();
  }

  /// Debug log
  ///
  /// Geliştirme aşamasında detaylı bilgi için kullanılır.
  /// Release build'de loglanmaz.
  void debug(String message, {Map<String, dynamic>? details}) {
    _log(LogLevel.debug, message, details: details);
  }

  /// Info log
  ///
  /// Genel bilgi mesajları için kullanılır.
  /// Örn: "Document imported", "User logged in"
  void info(String message, {Map<String, dynamic>? details}) {
    _log(LogLevel.info, message, details: details);
  }

  /// Warning log
  ///
  /// Uyarılar için kullanılır. Hata değil ama dikkat edilmeli.
  /// Örn: "Large file detected", "Slow network"
  void warning(String message, {Map<String, dynamic>? details, Object? error}) {
    _log(LogLevel.warning, message, details: details, error: error);
  }

  /// Error log
  ///
  /// Hatalar için kullanılır. Stack trace ile birlikte loglanır.
  /// Örn: "Failed to save document", "Database error"
  void error(
    String message, {
    Map<String, dynamic>? details,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      details: details,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Ana log metodu
  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? details,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Minimum seviye kontrolü
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      details: details,
      error: error,
      stackTrace: stackTrace,
    );

    // History'ye ekle
    _history.add(entry);
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }

    // Console'a yaz (debug modda)
    if (kDebugMode) {
      _printToConsole(entry);
    }

    // TODO: Production'da Crashlytics/Sentry'ye gönder
  }

  /// Console'a formatlı çıktı
  void _printToConsole(LogEntry entry) {
    final color = _getColorCode(entry.level);
    final reset = '\x1B[0m';

    // Ana mesaj
    debugPrint('$color${entry.toString()}$reset');

    // Error varsa
    if (entry.error != null) {
      debugPrint('$color  Error: ${entry.error}$reset');
    }

    // Stack trace varsa
    if (entry.stackTrace != null) {
      debugPrint('$color  StackTrace: ${entry.stackTrace}$reset');
    }
  }

  /// Log seviyesine göre renk kodu
  String _getColorCode(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[37m'; // Beyaz
      case LogLevel.info:
        return '\x1B[34m'; // Mavi
      case LogLevel.warning:
        return '\x1B[33m'; // Sarı
      case LogLevel.error:
        return '\x1B[31m'; // Kırmızı
    }
  }
}

/// Global logger instance
///
/// Kolay erişim için global değişken
final logger = AppLogger();
