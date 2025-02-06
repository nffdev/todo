import 'package:flutter/foundation.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  final List<Todo> _todos = [];
  Todo? _selectedTodo;

  List<Todo> get todos => List.unmodifiable(_todos);
  Todo? get selectedTodo => _selectedTodo;

  void addTodo(String title, {Todo? parent}) {
    if (title.isEmpty) return;
    
    if (parent != null) {
      _updateTodoInList(parent, (todo) {
        todo.subtasks.add(Todo(title: title));
      });
    } else {
      _todos.add(Todo(title: title));
    }
    _selectedTodo = null;
    notifyListeners();
  }

  void editTodo(
    Todo todo, {
    required String title,
    String? description,
    DateTime? deadline,
    required Priority priority,
  }) {
    _updateTodoInList(todo, (t) {
      t.title = title;
      t.description = description;
      t.deadline = deadline;
      t.priority = priority;
    });
  }

  void toggleTodo(Todo todo) {
    bool found = false;
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].id == todo.id) {
        _todos[i] = todo.copyWith(isDone: !todo.isDone);
        _updateSubtasks(_todos[i].subtasks, _todos[i].isDone);
        found = true;
        break;
      } else {
        found = _toggleSubtask(_todos[i].subtasks, todo);
        if (found) break;
      }
    }
    if (found) {
      notifyListeners();
    }
  }

  bool _toggleSubtask(List<Todo> subtasks, Todo target) {
    for (var i = 0; i < subtasks.length; i++) {
      if (subtasks[i].id == target.id) {
        subtasks[i] = target.copyWith(isDone: !target.isDone);
        _updateSubtasks(subtasks[i].subtasks, subtasks[i].isDone);
        return true;
      } else {
        if (_toggleSubtask(subtasks[i].subtasks, target)) {
          return true;
        }
      }
    }
    return false;
  }

  void _updateSubtasks(List<Todo> subtasks, bool isDone) {
    for (var i = 0; i < subtasks.length; i++) {
      subtasks[i] = subtasks[i].copyWith(isDone: isDone);
      _updateSubtasks(subtasks[i].subtasks, isDone);
    }
  }

  void removeTodo(Todo todo) {
    bool removed = false;
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].id == todo.id) {
        _todos.removeAt(i);
        removed = true;
        break;
      } else {
        removed = _removeSubtask(_todos[i].subtasks, todo);
        if (removed) break;
      }
    }
    if (removed) {
      notifyListeners();
    }
  }

  bool _removeSubtask(List<Todo> subtasks, Todo target) {
    for (var i = 0; i < subtasks.length; i++) {
      if (subtasks[i].id == target.id) {
        subtasks.removeAt(i);
        return true;
      } else {
        if (_removeSubtask(subtasks[i].subtasks, target)) {
          return true;
        }
      }
    }
    return false;
  }

  void toggleExpanded(Todo todo) {
    _updateTodoInList(todo, (t) {
      t.isExpanded = !t.isExpanded;
    });
  }

  void _updateTodoInList(Todo target, Function(Todo) update) {
    bool found = false;
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].id == target.id) {
        update(_todos[i]);
        found = true;
        break;
      } else {
        found = _updateSubtaskInList(_todos[i].subtasks, target, update);
        if (found) break;
      }
    }
    if (found) {
      notifyListeners();
    }
  }

  bool _updateSubtaskInList(List<Todo> subtasks, Todo target, Function(Todo) update) {
    for (var i = 0; i < subtasks.length; i++) {
      if (subtasks[i].id == target.id) {
        update(subtasks[i]);
        return true;
      } else {
        if (_updateSubtaskInList(subtasks[i].subtasks, target, update)) {
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
}
