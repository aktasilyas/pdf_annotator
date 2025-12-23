import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Database get instance {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  static Future<void> initialize() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pdf_annotator.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Documents tablosu
        await db.execute('''
          CREATE TABLE documents (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            file_path TEXT NOT NULL,
            thumbnail_path TEXT,
            page_count INTEGER DEFAULT 0,
            current_page INTEGER DEFAULT 0,
            file_size INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_opened_at TEXT
          )
        ''');

        // Annotations tablosu
        await db.execute('''
          CREATE TABLE annotations (
            id TEXT PRIMARY KEY,
            document_id TEXT NOT NULL,
            page_number INTEGER NOT NULL,
            type TEXT NOT NULL,
            color INTEGER NOT NULL,
            stroke_width REAL NOT NULL,
            opacity REAL NOT NULL,
            points TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_deleted INTEGER DEFAULT 0,
            z_index INTEGER DEFAULT 0,
            FOREIGN KEY (document_id) REFERENCES documents (id)
          )
        ''');
      },
    );
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
