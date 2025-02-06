import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/database_service.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Todo> _todos = [];
  Todo? _selectedTodo;

  List<Todo> get todos => List.unmodifiable(_todos);
  Todo? get selectedTodo => _selectedTodo;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    _todos = await _db.getAllTodos();
    notifyListeners();
  }

  Future<void> addTodo(String title, {Todo? parent}) async {
    if (title.isEmpty) return;
    
    final newTodo = Todo(title: title);
    
    if (parent != null) {
      await _updateTodoInList(parent, (todo) async {
        todo.subtasks.add(newTodo);
        await _db.insertTodo(newTodo, parentId: parent.id);
      });
    } else {
      _todos.add(newTodo);
      await _db.insertTodo(newTodo);
    }
    
    _selectedTodo = null;
    notifyListeners();
  }

  Future<void> editTodo(
    Todo todo, {
    required String title,
    String? description,
    DateTime? deadline,
    required Priority priority,
  }) async {
    await _updateTodoInList(todo, (t) async {
      t.title = title;
      t.description = description;
      t.deadline = deadline;
      t.priority = priority;
      await _db.updateTodo(t);
    });
  }

  Future<void> toggleTodo(Todo todo) async {
    bool found = false;
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].id == todo.id) {
        _todos[i] = todo.copyWith(isDone: !todo.isDone);
        await _updateSubtasks(_todos[i].subtasks, _todos[i].isDone);
        await _db.updateTodo(_todos[i]);
        found = true;
        break;
      } else {
        found = await _toggleSubtask(_todos[i].subtasks, todo);
        if (found) break;
      }
    }
    if (found) {
      notifyListeners();
    }
  }

  Future<bool> _toggleSubtask(List<Todo> subtasks, Todo target) async {
    for (var i = 0; i < subtasks.length; i++) {
      if (subtasks[i].id == target.id) {
        subtasks[i] = target.copyWith(isDone: !target.isDone);
        await _updateSubtasks(subtasks[i].subtasks, subtasks[i].isDone);
        await _db.updateTodo(subtasks[i]);
        return true;
      } else {
        if (await _toggleSubtask(subtasks[i].subtasks, target)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _updateSubtasks(List<Todo> subtasks, bool isDone) async {
    for (var i = 0; i < subtasks.length; i++) {
      subtasks[i] = subtasks[i].copyWith(isDone: isDone);
      await _db.updateTodo(subtasks[i]);
      await _updateSubtasks(subtasks[i].subtasks, isDone);
    }
  }

  Future<void> removeTodo(Todo todo) async {
    bool removed = false;
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].id == todo.id) {
        await _db.deleteTodo(todo.id);
        _todos.removeAt(i);
        removed = true;
        break;
      } else {
        removed = await _removeSubtask(_todos[i].subtasks, todo);
        if (removed) break;
      }
    }
    if (removed) {
      notifyListeners();
    }
  }

  Future<bool> _removeSubtask(List<Todo> subtasks, Todo target) async {
    for (var i = 0; i < subtasks.length; i++) {
      if (subtasks[i].id == target.id) {
        await _db.deleteTodo(target.id);
        subtasks.removeAt(i);
        return true;
      } else {
        if (await _removeSubtask(subtasks[i].subtasks, target)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> toggleExpanded(Todo todo) async {
    await _updateTodoInList(todo, (t) async {
      t.isExpanded = !t.isExpanded;
      await _db.updateTodo(t);
    });
  }

  Future<void> _updateTodoInList(Todo target, Function(Todo) update) async {
    bool found = false;
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].id == target.id) {
        await update(_todos[i]);
        found = true;
        break;
      } else {
        found = await _updateSubtaskInList(_todos[i].subtasks, target, update);
        if (found) break;
      }
    }
    if (found) {
      notifyListeners();
    }
  }

  Future<bool> _updateSubtaskInList(List<Todo> subtasks, Todo target, Function(Todo) update) async {
    for (var i = 0; i < subtasks.length; i++) {
      if (subtasks[i].id == target.id) {
        await update(subtasks[i]);
        return true;
      } else {
        if (await _updateSubtaskInList(subtasks[i].subtasks, target, update)) {
          return true;
        }
      }
    }
    return false;
  }

  void setSelectedTodo(Todo? todo) {
    _selectedTodo = todo;
    notifyListeners();
  }

  Future<List<Todo>> searchTodos(String query) async {
    if (query.isEmpty) return [];
    return _db.searchTodos(query);
  }
}
