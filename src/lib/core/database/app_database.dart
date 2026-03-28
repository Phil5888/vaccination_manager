import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'vaccination_manager.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        profile_picture_path TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE vaccinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        shot_number INTEGER NOT NULL DEFAULT 1,
        total_shots INTEGER NOT NULL DEFAULT 1,
        vaccination_date TEXT,
        next_vaccination_date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE vaccinations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          vaccination_date TEXT NOT NULL,
          next_vaccination_date TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS vaccinations');
      await db.execute('''
        CREATE TABLE vaccinations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          shot_number INTEGER NOT NULL DEFAULT 1,
          total_shots INTEGER NOT NULL DEFAULT 1,
          vaccination_date TEXT,
          next_vaccination_date TEXT
        )
      ''');
    }
  }
}
