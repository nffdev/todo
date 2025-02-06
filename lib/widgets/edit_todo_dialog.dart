import 'package:flutter/material.dart';
import '../models/todo.dart';

class EditTodoDialog extends StatefulWidget {
  final Todo todo;
  final Function(String) onSave;

  const EditTodoDialog({
    super.key,
    required this.todo,
    required this.onSave,
  });

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la tâche'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Titre de la tâche',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onSave(value);
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSave(_controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
