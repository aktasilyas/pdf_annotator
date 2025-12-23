import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_annotator/app.dart';
import 'package:pdf_annotator/database/database_service.dart';

void main() async {
  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanını başlat
  await DatabaseService.initialize();

  // Uygulamayı başlat
  runApp(const ProviderScope(child: PdfAnnotatorApp()));
}
