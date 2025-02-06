import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final bool isSubtask;

  const TodoItem({
    super.key,
    required this.todo,
    this.isSubtask = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) {
              context.read<TodoProvider>().toggleTodo(todo);
            },
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
                  onPressed: () {
                    context.read<TodoProvider>().toggleExpanded(todo);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  context.read<TodoProvider>().setSelectedTodo(todo);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  context.read<TodoProvider>().removeTodo(todo);
                },
              ),
            ],
          ),
        ),
        if (todo.isExpanded && todo.subtasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              children: todo.subtasks
                  .map((subtask) => TodoItem(
                        todo: subtask,
                        isSubtask: true,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
