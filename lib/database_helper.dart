import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'event.dart';

/// Clase DatabaseHelper para manejar SQLite
/// Métodos:
/// - initDatabase(): inicializa DB
/// - insertEvent(Event event)
/// - getEvents(): retorna lista de eventos ordenada por fecha
/// - updateEvent(Event event)
/// - deleteEvent(int id)
/// Usa sqflite y path_provider para obtener ruta local.
/// La tabla se llama 'events' con columnas id, title, targetDate, message.

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _databaseVersion = 6;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, fileName);
    return await openDatabase(
      path, 
      version: _databaseVersion, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        targetDate TEXT NOT NULL,
        message TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'other',
        color TEXT NOT NULL DEFAULT 'orange',
        icon TEXT NOT NULL DEFAULT 'celebration'
      )
    ''');
    
    // Crear tabla de preparativos
    await db.execute('''
      CREATE TABLE preparation_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        daysBeforeEvent INTEGER NOT NULL,
        completedAt TEXT,
        FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');
    
    // Crear tabla de estrategias para retos
    await db.execute('''
      CREATE TABLE challenge_strategies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        challengeId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 3,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt INTEGER,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE events ADD COLUMN category TEXT NOT NULL DEFAULT "other"');
    }
    
    // Migración adicional para corregir categorías en español a IDs
    if (oldVersion < 3) {
      await db.execute('UPDATE events SET category = "other" WHERE category = "Otro" OR category = "Other"');
      await db.execute('UPDATE events SET category = "birthday" WHERE category = "Cumpleaños" OR category = "Birthday"');
      await db.execute('UPDATE events SET category = "vacation" WHERE category = "Vacaciones" OR category = "Vacation"');
      await db.execute('UPDATE events SET category = "work" WHERE category = "Trabajo" OR category = "Work"');
      await db.execute('UPDATE events SET category = "family" WHERE category = "Familia" OR category = "Family"');
      await db.execute('UPDATE events SET category = "health" WHERE category = "Salud" OR category = "Health"');
      await db.execute('UPDATE events SET category = "education" WHERE category = "Educación" OR category = "Education"');
      await db.execute('UPDATE events SET category = "holiday" WHERE category = "Festivo" OR category = "Holiday"');
    }
    
    // Migración para personalización visual (versión 4)
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE events ADD COLUMN color TEXT NOT NULL DEFAULT "orange"');
      await db.execute('ALTER TABLE events ADD COLUMN icon TEXT NOT NULL DEFAULT "celebration"');
    }
    
    // Migración para tabla de preparativos (versión 5)
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE preparation_tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          eventId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          daysBeforeEvent INTEGER NOT NULL,
          completedAt TEXT,
          FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
        )
      ''');
    }
    
    // Migración para tabla de estrategias de retos (versión 6)
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE challenge_strategies (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          challengeId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          priority INTEGER NOT NULL DEFAULT 3,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          completedAt INTEGER,
          createdAt INTEGER NOT NULL
        )
      ''');
    }
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
