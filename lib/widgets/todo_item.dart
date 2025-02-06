import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'edit_todo_dialog.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final bool isSubtask;

  const TodoItem({
    super.key,
    required this.todo,
    this.isSubtask = false,
  });

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(
        todo: todo,
        onSave: (title, description, deadline, priority) {
          context.read<TodoProvider>().editTodo(
                todo,
                title: title,
                description: description,
                deadline: deadline,
                priority: priority,
              );
        },
      ),
    );
  }

  Color _getPriorityColor() {
    switch (todo.priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon() {
    switch (todo.priority) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(
            left: isSubtask ? 0 : 8,
            right: 8,
            top: 4,
            bottom: 4,
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: todo.isDone,
                  onChanged: (_) {
                    context.read<TodoProvider>().toggleTodo(todo);
                  },
                ),
                Icon(
                  _getPriorityIcon(),
                  color: _getPriorityColor(),
                ),
              ],
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: todo.description != null || todo.deadline != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todo.description != null) ...[
                        const SizedBox(height: 4),
                        Text(todo.description!),
                      ],
                      if (todo.deadline != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${todo.deadline!.day}/${todo.deadline!.month}/${todo.deadline!.year}',
                            ),
                          ],
                        ),
                      ],
                    ],
                  )
                : null,
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
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context),
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
