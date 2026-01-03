/// Safe JSON Parser
///
/// JSON parsing işlemlerini güvenli hale getirir.
/// Malformed JSON veya eksik field'lar için hata yakalamayı sağlar.
library;

import 'dart:convert';
import 'package:pdf_annotator/core/errors/exceptions.dart';
import 'package:pdf_annotator/core/constants/app_constants.dart';

/// Safe JSON Parser Utility
class JsonParser {
  JsonParser._();

  /// JSON string'i güvenli bir şekilde decode eder
  ///
  /// [jsonString]: Decode edilecek JSON string
  /// Returns: Decoded object (Map veya List)
  /// Throws: [ValidationException] JSON geçersizse
  static dynamic safeDecode(String jsonString) {
    if (jsonString.isEmpty) {
      throw const ValidationException(
        message: 'JSON string boş olamaz',
        field: 'jsonString',
      );
    }

    try {
      final decoded = jsonDecode(jsonString);
      return decoded;
    } on FormatException catch (e, st) {
      throw ValidationException(
        message: ErrorMessages.jsonDecodeFailed,
        field: 'jsonString',
        originalError: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw ValidationException(
        message: ErrorMessages.jsonDecodeFailed,
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// List<Map<String, dynamic>> olarak decode eder
  ///
  /// [jsonString]: JSON string
  /// Returns: List of maps
  /// Throws: [ValidationException] format hatalıysa
  static List<Map<String, dynamic>> decodeList(String jsonString) {
    final decoded = safeDecode(jsonString);

    if (decoded is! List) {
      throw ValidationException(
        message: 'JSON bir liste değil',
        field: 'jsonString',
        originalError: 'Expected List, got ${decoded.runtimeType}',
      );
    }

    try {
      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw ValidationException(
            message: 'Liste elemanı Map<String, dynamic> değil',
            field: 'jsonString',
            originalError: 'Expected Map, got ${item.runtimeType}',
          );
        }
        return item;
      }).toList();
    } catch (e, st) {
      throw ValidationException(
        message: ErrorMessages.jsonDecodeFailed,
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Map<String, dynamic> olarak decode eder
  ///
  /// [jsonString]: JSON string
  /// Returns: Map
  /// Throws: [ValidationException] format hatalıysa
  static Map<String, dynamic> decodeMap(String jsonString) {
    final decoded = safeDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw ValidationException(
        message: 'JSON bir map değil',
        field: 'jsonString',
        originalError: 'Expected Map, got ${decoded.runtimeType}',
      );
    }

    return decoded;
  }

  /// Object'i JSON string'e encode eder
  ///
  /// [object]: Encode edilecek object
  /// Returns: JSON string
  /// Throws: [ValidationException] encode başarısızsa
  static String safeEncode(dynamic object) {
    try {
      return jsonEncode(object);
    } catch (e, st) {
      throw ValidationException(
        message: 'JSON encode başarısız',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Map'ten required field alır
  ///
  /// [map]: Source map
  /// [key]: Field key
  /// [fieldName]: Hata mesajı için field adı
  /// Returns: Field value
  /// Throws: [ValidationException] field yoksa veya null ise
  static T getRequiredField<T>(
    Map<String, dynamic> map,
    String key, {
    String? fieldName,
  }) {
    if (!map.containsKey(key)) {
      throw ValidationException(
        message: '${fieldName ?? key} alanı bulunamadı',
        field: key,
      );
    }

    final value = map[key];

    if (value == null) {
      throw ValidationException(
        message: '${fieldName ?? key} alanı null olamaz',
        field: key,
      );
    }

    if (value is! T) {
      throw ValidationException(
        message:
            '${fieldName ?? key} alanı geçersiz tip. Beklenen: $T, Gelen: ${value.runtimeType}',
        field: key,
      );
    }

    return value;
  }

  /// Map'ten optional field alır
  ///
  /// [map]: Source map
  /// [key]: Field key
  /// [defaultValue]: Field yoksa dönülecek default değer
  /// Returns: Field value veya default
  static T? getOptionalField<T>(
    Map<String, dynamic> map,
    String key, {
    T? defaultValue,
  }) {
    if (!map.containsKey(key)) {
      return defaultValue;
    }

    final value = map[key];

    if (value == null) {
      return defaultValue;
    }

    if (value is! T) {
      return defaultValue;
    }

    return value;
  }

  /// Numeric field'i double'a çevirir (int veya double kabul eder)
  ///
  /// Database'den gelen numeric değerler bazen int bazen double olabilir
  static double getNumericField(
    Map<String, dynamic> map,
    String key, {
    String? fieldName,
  }) {
    final value = getRequiredField<num>(map, key, fieldName: fieldName);
    return value.toDouble();
  }

  /// Optional numeric field alır
  static double? getOptionalNumericField(
    Map<String, dynamic> map,
    String key, {
    double? defaultValue,
  }) {
    if (!map.containsKey(key)) {
      return defaultValue;
    }

    final value = map[key];

    if (value == null) {
      return defaultValue;
    }

    if (value is num) {
      return value.toDouble();
    }

    return defaultValue;
  }

  /// DateTime string'ini parse eder
  ///
  /// ISO8601 format beklenir
  static DateTime getDateTimeField(
    Map<String, dynamic> map,
    String key, {
    String? fieldName,
  }) {
    final value = getRequiredField<String>(map, key, fieldName: fieldName);

    try {
      return DateTime.parse(value);
    } catch (e, st) {
      throw ValidationException(
        message: '${fieldName ?? key} geçersiz tarih formatı',
        field: key,
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Boolean field alır (0/1 veya true/false kabul eder)
  ///
  /// SQLite boolean'ları 0/1 olarak saklar
  static bool getBooleanField(
    Map<String, dynamic> map,
    String key, {
    String? fieldName,
  }) {
    final value = map[key];

    if (value == null) {
      throw ValidationException(
        message: '${fieldName ?? key} alanı bulunamadı',
        field: key,
      );
    }

    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }

    throw ValidationException(
      message: '${fieldName ?? key} boolean değere çevrilemedi',
      field: key,
      originalError: 'Invalid boolean value: $value',
    );
  }

  /// Enum value alır
  ///
  /// [values]: Enum.values listesi
  /// [fromString]: String'den enum'a çeviren function
  static T getEnumField<T>(
    Map<String, dynamic> map,
    String key,
    T Function(String) fromString, {
    String? fieldName,
  }) {
    final value = getRequiredField<String>(map, key, fieldName: fieldName);

    try {
      return fromString(value);
    } catch (e, st) {
      throw ValidationException(
        message: '${fieldName ?? key} geçersiz enum değeri',
        field: key,
        originalError: e,
        stackTrace: st,
      );
    }
  }
}
