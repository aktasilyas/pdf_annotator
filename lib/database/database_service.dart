import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pdf_annotator/core/errors/exceptions.dart';
import 'package:pdf_annotator/core/constants/app_constants.dart';

class DatabaseService {
  static Database? _database;

  static Database get instance {
    if (_database == null) {
      throw const AppDatabaseException(
        message: ErrorMessages.databaseNotInitialized,
      );
    }
    return _database!;
  }

  static Future<void> initialize() async {
    if (_database != null) return;

    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DatabaseConstants.databaseName);

      _database = await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Veritabanı başlatılamadı',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    try {
      // Documents tablosu
      await db.execute('''
        CREATE TABLE ${DatabaseConstants.documentsTable} (
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
        CREATE TABLE ${DatabaseConstants.annotationsTable} (
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
          FOREIGN KEY (document_id) REFERENCES ${DatabaseConstants.documentsTable} (id) ON DELETE CASCADE
        )
      ''');

      // Performance için indexler ekle
      await _createIndexes(db);
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Veritabanı tabloları oluşturulamadı',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> _createIndexes(Database db) async {
    try {
      // Annotations için sık kullanılan query'lerde index
      await db.execute('''
        CREATE INDEX idx_annotations_document_page
        ON ${DatabaseConstants.annotationsTable}(document_id, page_number)
      ''');

      await db.execute('''
        CREATE INDEX idx_annotations_document
        ON ${DatabaseConstants.annotationsTable}(document_id)
      ''');

      await db.execute('''
        CREATE INDEX idx_annotations_page
        ON ${DatabaseConstants.annotationsTable}(page_number)
      ''');

      // Documents için index
      await db.execute('''
        CREATE INDEX idx_documents_updated
        ON ${DatabaseConstants.documentsTable}(updated_at DESC)
      ''');
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Veritabanı indexleri oluşturulamadı',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Future migrations will be handled here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  static Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
    } catch (e, st) {
      throw AppDatabaseException(
        message: 'Veritabanı kapatılamadı',
        originalError: e,
        stackTrace: st,
      );
    }
  }
}
