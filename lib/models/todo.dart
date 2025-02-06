class Todo {
  String id;
  String title;
  bool isDone;
  List<Todo> subtasks;
  bool isExpanded;

  Todo({
    required this.title,
    String? id,
    this.isDone = false,
    List<Todo>? subtasks,
    this.isExpanded = false,
  })  : id = id ?? DateTime.now().toString(),
        subtasks = subtasks ?? [];

  Todo copyWith({
    String? id,
    String? title,
    bool? isDone,
    List<Todo>? subtasks,
    bool? isExpanded,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      subtasks: subtasks ?? this.subtasks,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
