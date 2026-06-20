class Todo {
  final String title;
  final DateTime deadline;
  final Priority priority;

  Todo({required this.title, required this.deadline, required this.priority});

  Map<String, dynamic> toJson() => {
    'title': title,
    'deadline': deadline.toIso8601String(),
    'priority': priority.index,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    title: json['title'],
    deadline: DateTime.parse(json['deadline']),
    priority: Priority.values[json['priority']],
  );
}

enum Priority { low, medium, high }
