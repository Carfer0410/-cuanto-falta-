/// Clase DatabaseHelper para manejar SQLite
/// Métodos:
/// - initDatabase(): inicializa DB
/// - insertEvent(Event event)
/// - getEvents(): retorna lista de eventos ordenada por fecha
/// - updateEvent(Event event)
/// - deleteEvent(int id)
/// Usa sqflite y path_provider para obtener ruta local.
/// La tabla se llama 'events' con columnas id, title, targetDate, message.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'event.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        targetDate TEXT NOT NULL,
        message TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertEvent(Event event) async {
    final db = await instance.database;
    return await db.insert('events', event.toMap());
  }

  Future<List<Event>> getEvents() async {
    final db = await instance.database;
    final result = await db.query('events', orderBy: 'targetDate ASC');
    return result.map((json) => Event.fromMap(json)).toList();
  }

  Future<int> updateEvent(Event event) async {
    final db = await instance.database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
