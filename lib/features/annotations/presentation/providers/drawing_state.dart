/// Drawing State
///
/// Çizim durumunu tutan immutable state sınıfı.
/// Seçili araç, renk, kalınlık ve aktif çizim bilgilerini içerir.
library;

import 'package:flutter/material.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_tool.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/stroke.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/highlight.dart';

class DrawingState {
  /// Seçili çizim aracı
  final DrawingTool selectedTool;

  /// Seçili renk
  final Color selectedColor;

  /// Çizgi kalınlığı
  final double strokeWidth;

  /// Fosforlu kalem kalınlığı
  final double highlightWidth;

  /// Sayfadaki stroke'lar
  final List<Stroke> strokes;

  /// Sayfadaki highlight'lar
  final List<Highlight> highlights;

  /// Şu an çizilen stroke (henüz tamamlanmamış)
  final Stroke? currentStroke;

  /// Şu an çizilen highlight (henüz tamamlanmamış)
  final Highlight? currentHighlight;

  /// Yükleniyor mu?
  final bool isLoading;

  /// Hata mesajı
  final String? errorMessage;

  const DrawingState({
    this.selectedTool = DrawingTool.none,
    this.selectedColor = Colors.black,
    this.strokeWidth = 3.0,
    this.highlightWidth = 20.0,
    this.strokes = const [],
    this.highlights = const [],
    this.currentStroke,
    this.currentHighlight,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Initial state
  factory DrawingState.initial() {
    return const DrawingState(isLoading: true);
  }

  /// Kopya oluştur
  DrawingState copyWith({
    DrawingTool? selectedTool,
    Color? selectedColor,
    double? strokeWidth,
    double? highlightWidth,
    List<Stroke>? strokes,
    List<Highlight>? highlights,
    Stroke? currentStroke,
    Highlight? currentHighlight,
    bool? isLoading,
    String? errorMessage,
    bool clearCurrentStroke = false,
    bool clearCurrentHighlight = false,
    bool clearError = false,
  }) {
    return DrawingState(
      selectedTool: selectedTool ?? this.selectedTool,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      highlightWidth: highlightWidth ?? this.highlightWidth,
      strokes: strokes ?? this.strokes,
      highlights: highlights ?? this.highlights,
      currentStroke: clearCurrentStroke
          ? null
          : (currentStroke ?? this.currentStroke),
      currentHighlight: clearCurrentHighlight
          ? null
          : (currentHighlight ?? this.currentHighlight),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Tüm çizimleri birleştir (render için)
  List<dynamic> get allAnnotations {
    final all = <dynamic>[...strokes, ...highlights];
    // Z-index'e göre sırala
    all.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return all;
  }
}
