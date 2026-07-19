// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/todo.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDeadline;
  Priority _selectedPriority = Priority.low;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('todos') ?? [];
    setState(() {
      _todos.clear();
      _todos.addAll(stored.map((e) => Todo.fromJson(jsonDecode(e))));
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _todos.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('todos', list);
  }

  void _addTodo() {
    if (_controller.text.trim().isNotEmpty) {
      final todo = Todo(
        title: _controller.text.trim(),
        //deadline: _selectedDeadline ?? DateTime.now(), // deadline yoksa şu an
        deadline: _selectedDeadline, // deadline yoksa şu an
        priority: _selectedPriority, // default low
      );
      setState(() => _todos.add(todo));
      _controller.clear();
      // _selectedDeadline = null;
      _selectedPriority = Priority.low; // her eklemeden sonra default low
      print(
        'test: ${todo.title}, ${todo.deadline}, ${todo.priority}, ${_selectedDeadline}',
      );
      _saveTodos();
      if (todo.deadline != null && todo.deadline!.isAfter(DateTime.now())) {
        _scheduleNotification(todo);
      }
    }
  }

  void _deleteTodo(int index) {
    setState(() => _todos.removeAt(index));
    _saveTodos(); // silince kaydet
  }

  void _scheduleNotification(Todo todo) {
    print(
      'Bildirim planlanıyor: ${todo.title} için ${todo.deadline} tarihinde',
    );
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: todo.deadline!.millisecondsSinceEpoch.remainder(
          100000,
        ), // benzersiz ID
        channelKey: todo.priority == Priority.high
            ? 'high_priority_channel'
            : 'todo_channel',
        title: todo.title,
        body: 'Deadline geldi!',
      ),
      schedule: NotificationCalendar(
        year: todo.deadline!.year,
        month: todo.deadline!.month,
        day: todo.deadline!.day,
        hour: todo.deadline!.hour,
        minute: todo.deadline!.minute,
        second: 0,
        repeats: false,
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green.shade50;
      case Priority.medium:
        return Colors.orange.shade50;
      case Priority.high:
        return Colors.red.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Yeni görev ekle...",
                        border: InputBorder.none,
                      ),
                    ),
                    Row(
                      children: [
                        DropdownButton<Priority>(
                          value: _selectedPriority,
                          items: Priority.values.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPriority = val);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDeadline == null
                                ? "Deadline seç"
                                : DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(_selectedDeadline!),
                          ),
                          onPressed: _pickDeadline,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.blue,
                          ),
                          onPressed: _addTodo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _todos.isEmpty
                  ? const Center(child: Text("Henüz görev yok"))
                  : ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final todo = _todos[index];
                        return Card(
                          color: _getPriorityColor(todo.priority),
                          child: ListTile(
                            title: Text(todo.title),
                            subtitle: Text(
                              "Deadline: ${todo.deadline == null ? 'Yok' : DateFormat('dd/MM/yyyy HH:mm').format(todo.deadline!)}\n"
                              "Önem: ${todo.priority.name.toUpperCase()}",
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteTodo(index), // 🔑 burada kullanılıyor
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
