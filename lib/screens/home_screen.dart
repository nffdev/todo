import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatelessWidget {
  final String title;
  final _textController = TextEditingController();

  HomeScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Column(
        children: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: todoProvider.selectedTodo != null
                              ? 'Ajouter une sous-tâche à "${todoProvider.selectedTodo!.title}"'
                              : 'Ajouter une tâche',
                          border: const OutlineInputBorder(),
                          prefixIcon: todoProvider.selectedTodo != null
                              ? IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                    todoProvider.setSelectedTodo(null);
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            todoProvider.addTodo(
                              value,
                              parent: todoProvider.selectedTodo,
                            );
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          todoProvider.addTodo(
                            _textController.text,
                            parent: todoProvider.selectedTodo,
                          );
                          _textController.clear();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                return ListView.builder(
                  itemCount: todoProvider.todos.length,
                  itemBuilder: (context, index) {
                    return TodoItem(todo: todoProvider.todos[index]);
                  },
                );
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
  }
}
