import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _initPlatformSpecific();
  }

  void _initPlatformSpecific() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        deadline INTEGER,
        createdAt INTEGER NOT NULL,
        priority TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        isExpanded INTEGER NOT NULL,
        parentId TEXT,
        FOREIGN KEY (parentId) REFERENCES todos (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertTodo(Todo todo, {String? parentId}) async {
    final Database db = await database;
    await db.insert(
      'todos',
      {
        'id': todo.id,
        'title': todo.title,
        'description': todo.description,
        'deadline': todo.deadline?.millisecondsSinceEpoch,
        'createdAt': todo.createdAt.millisecondsSinceEpoch,
        'priority': todo.priority.toString(),
        'isDone': todo.isDone ? 1 : 0,
        'isExpanded': todo.isExpanded ? 1 : 0,
        'parentId': parentId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var subtask in todo.subtasks) {
      await insertTodo(subtask, parentId: todo.id);
    }
  }

  Future<List<Todo>> getAllTodos() async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> rootTodos = await db.query(
      'todos',
      where: 'parentId IS NULL',
    );

    return Future.wait(
      rootTodos.map((todo) => _convertToTodo(todo)).toList(),
    );
  }

  Future<Todo> _convertToTodo(Map<String, dynamic> todoMap) async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> subtaskMaps = await db.query(
      'todos',
      where: 'parentId = ?',
      whereArgs: [todoMap['id']],
    );

    final List<Todo> subtasks = await Future.wait(
      subtaskMaps.map((subtask) => _convertToTodo(subtask)).toList(),
    );

    return Todo(
      id: todoMap['id'],
      title: todoMap['title'],
      description: todoMap['description'],
      deadline: todoMap['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(todoMap['deadline'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(todoMap['createdAt']),
      priority: Priority.values.firstWhere(
        (p) => p.toString() == todoMap['priority'],
      ),
      isDone: todoMap['isDone'] == 1,
      isExpanded: todoMap['isExpanded'] == 1,
      subtasks: subtasks,
    );
  }

  Future<void> updateTodo(Todo todo) async {
    final Database db = await database;
    await db.update(
      'todos',
      {
        'title': todo.title,
        'description': todo.description,
        'deadline': todo.deadline?.millisecondsSinceEpoch,
        'priority': todo.priority.toString(),
        'isDone': todo.isDone ? 1 : 0,
        'isExpanded': todo.isExpanded ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final Database db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Todo>> searchTodos(String query) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return Future.wait(maps.map((todo) => _convertToTodo(todo)).toList());
  }
}
