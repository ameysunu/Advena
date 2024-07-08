import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlController {
  static final SqlController _instance = SqlController._internal();
  factory SqlController() => _instance;

  static Database? _database;

  SqlController._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'advena.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createForDB,
    );
  }

  Future<void> _createForDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE advena_worker (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> createTable(Database db, String query) async {
    await db.execute('''
      $query
    ''');
  }

  Future<int> insertItem(String name, String value, String tableName,
      Map<String, Object?> dbContent) async {
    final db = await database;
    return await db.insert(
      tableName,
      dbContent,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getItems(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> deleteItem(int id, String tableName) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateItem(int id, String name, String value, String tableName,
      Map<String, Object?> dbContent) async {
    final db = await database;
    return await db.update(
      tableName,
      dbContent,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isTableExists(String tableName) async {
    final db = await database;
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }
}
