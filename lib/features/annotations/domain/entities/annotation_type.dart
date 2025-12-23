/// Annotation Type Enum
///
/// Desteklenen annotation tiplerini tanımlar.
/// Her tip farklı render ve davranış mantığına sahiptir.
library;

enum AnnotationType {
  /// Kalem çizimi - opak, normal blend mode
  stroke,

  /// Fosforlu kalem - yarı saydam, multiply blend mode
  highlight,

  /// Metin notu - sticky note şeklinde (Post-MVP)
  textNote,
}

/// AnnotationType extension metodları
extension AnnotationTypeExtension on AnnotationType {
  /// Enum değerini string'e çevirir (DB için)
  String toDbString() {
    switch (this) {
      case AnnotationType.stroke:
        return 'stroke';
      case AnnotationType.highlight:
        return 'highlight';
      case AnnotationType.textNote:
        return 'text_note';
    }
  }

  /// String'den enum değeri oluşturur (DB'den okurken)
  static AnnotationType fromDbString(String value) {
    switch (value) {
      case 'stroke':
        return AnnotationType.stroke;
      case 'highlight':
        return AnnotationType.highlight;
      case 'text_note':
        return AnnotationType.textNote;
      default:
        return AnnotationType.stroke;
    }
  }
}
