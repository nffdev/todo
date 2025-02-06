enum Priority { low, medium, high }

class Todo {
  String id;
  String title;
  String? description;
  DateTime? deadline;
  DateTime createdAt;
  Priority priority;
  bool isDone;
  List<Todo> subtasks;
  bool isExpanded;

  Todo({
    required this.title,
    String? id,
    this.description,
    this.deadline,
    DateTime? createdAt,
    this.priority = Priority.medium,
    this.isDone = false,
    List<Todo>? subtasks,
    this.isExpanded = false,
  })  : id = id ?? DateTime.now().toString(),
        createdAt = createdAt ?? DateTime.now(),
        subtasks = subtasks ?? [];

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    DateTime? createdAt,
    Priority? priority,
    bool? isDone,
    List<Todo>? subtasks,
    bool? isExpanded,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      subtasks: subtasks ?? this.subtasks,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
