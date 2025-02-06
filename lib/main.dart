import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ma Todo List'),
    );
  }
}

class Todo {
  String title;
  bool isDone;
  List<Todo> subtasks;
  bool isExpanded;

  Todo({
    required this.title, 
    this.isDone = false, 
    List<Todo>? subtasks,
    this.isExpanded = false,
  }) : subtasks = subtasks ?? [];
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  Todo? _selectedTodo;

  void _addTodo({Todo? parent}) {
    if (_textController.text.isEmpty) return;
    
    setState(() {
      final newTodo = Todo(title: _textController.text);
      if (parent != null) {
        parent.subtasks.add(newTodo);
      } else {
        _todos.add(newTodo);
      }
      _textController.clear();
      _selectedTodo = null;
    });
  }

  void _toggleTodo(Todo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      // Mettre à jour également l'état des sous-tâches
      for (var subtask in todo.subtasks) {
        subtask.isDone = todo.isDone;
      }
    });
  }

  void _removeTodo(Todo todo, {Todo? parent}) {
    setState(() {
      if (parent != null) {
        parent.subtasks.remove(todo);
      } else {
        _todos.remove(todo);
      }
    });
  }

  void _toggleExpanded(Todo todo) {
    setState(() {
      todo.isExpanded = !todo.isExpanded;
    });
  }

  Widget _buildTodoItem(Todo todo, {Todo? parent}) {
    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) => _toggleTodo(todo),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (todo.subtasks.isNotEmpty)
                IconButton(
                  icon: Icon(
                    todo.isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () => _toggleExpanded(todo),
                ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _selectedTodo = todo;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeTodo(todo, parent: parent),
              ),
            ],
          ),
        ),
        if (todo.isExpanded && todo.subtasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              children: todo.subtasks
                  .map((subtask) => _buildTodoItem(subtask, parent: todo))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: _selectedTodo != null 
                          ? 'Ajouter une sous-tâche à "${_selectedTodo!.title}"'
                          : 'Ajouter une tâche',
                      border: const OutlineInputBorder(),
                      prefixIcon: _selectedTodo != null
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  _selectedTodo = null;
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _addTodo(parent: _selectedTodo),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTodo(parent: _selectedTodo),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return _buildTodoItem(_todos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
