class Todo {
  final String title;
  final DateTime deadline;
  final Priority priority;

  Todo({required this.title, required this.deadline, required this.priority});
}

enum Priority { low, medium, high }
