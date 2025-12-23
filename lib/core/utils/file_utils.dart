import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FileUtils {
  static const _uuid = Uuid();

  /// PDF dosyası seç
  static Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return null;

    final filePath = result.files.single.path;
    if (filePath == null) return null;

    return File(filePath);
  }

  /// Dosyayı uygulama dizinine kopyala
  static Future<File> copyToAppDirectory(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${appDir.path}/pdfs');

    // Klasör yoksa oluştur
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    // Unique dosya adı
    final extension = path.extension(file.path);
    final uniqueName = '${_uuid.v4()}$extension';
    final newPath = '${pdfDir.path}/$uniqueName';

    // Kopyala
    return await file.copy(newPath);
  }

  /// Dosya adını al (extension olmadan)
  static String getFileName(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Dosya boyutunu al
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Dosyayı sil
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
