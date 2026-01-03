import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;
  static bool _initialized = false;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  static Future<void> initialize() async {
    if (_initialized) return;
    
    if (kIsWeb) {
      // For web, use databaseFactoryFfiWeb
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // For desktop platforms, use databaseFactoryFfi
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Ensure database factory is initialized
    if (!_initialized) {
      await initialize();
    }

    String path;
    
    if (kIsWeb) {
      // For web, sqflite uses IndexedDB, path is just a name
      path = 'habit_tracker.db';
      // Use databaseFactory for web
      return await databaseFactory!.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      // For mobile platforms, use file system
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'habit_tracker.db');
      // Use databaseFactory for desktop, standard for mobile
      if (databaseFactory != null) {
      return await databaseFactory!.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table: habits
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        minimal_action TEXT NOT NULL,
        frequency TEXT NOT NULL,
        reminder_time TEXT,
        created_at INTEGER NOT NULL,
        goal_type TEXT,
        target_value INTEGER,
        unit TEXT
      )
    ''');

    // Table: habit_tracking
    await db.execute('''
      CREATE TABLE habit_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        current_value INTEGER,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');

    // Index for faster queries
    await db.execute('''
      CREATE INDEX idx_habit_tracking_habit_id ON habit_tracking(habit_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_habit_tracking_date ON habit_tracking(date)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for goal tracking
      try {
        await db.execute('ALTER TABLE habits ADD COLUMN goal_type TEXT');
        await db.execute('ALTER TABLE habits ADD COLUMN target_value INTEGER');
        await db.execute('ALTER TABLE habits ADD COLUMN unit TEXT');
        await db.execute('ALTER TABLE habit_tracking ADD COLUMN current_value INTEGER');
      } catch (e) {
        // Columns might already exist, ignore error
        if (kDebugMode) {
          print('Migration error (might be expected): $e');
        }
      }
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

