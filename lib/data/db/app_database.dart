import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  // ... imports

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        icon_key TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER NOT NULL,
        event_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL,
        remind_enabled INTEGER NOT NULL DEFAULT 0,
        remind_minutes INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,  -- เพิ่มคอลัมน์นี้
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Default Categories
    await db.insert('categories', Category(name: 'งาน', colorHex: '#2196F3', iconKey: 'work').toMap());
    await db.insert('categories', Category(name: 'ส่วนตัว', colorHex: '#4CAF50', iconKey: 'person').toMap());
    await db.insert('categories', Category(name: 'เรียน', colorHex: '#FF9800', iconKey: 'school').toMap());
    await db.insert('categories', Category(name: 'อื่นๆ', colorHex: '#9E9E9E', iconKey: 'label').toMap());
  }

  // getter that returns an initialized database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
}
