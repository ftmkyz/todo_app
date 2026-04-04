// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/services/notification_service.dart';
import '../../domain/todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDeadline;
  Priority _selectedPriority = Priority.medium;

  void _addTodo() {
    if (_controller.text.trim().isNotEmpty && _selectedDeadline != null) {
      final todo = Todo(
        title: _controller.text.trim(),
        deadline: _selectedDeadline!,
        priority: _selectedPriority,
      );
      setState(() => _todos.add(todo));
      _controller.clear();
      _selectedDeadline = null;

      // 🔔 Bildirim planlama (örnek)
      _scheduleNotification(todo);
    }
  }

  void _scheduleNotification(Todo todo) {
    NotificationService.scheduleNotification(
      id: _todos.length, // benzersiz id
      title: "Görev Hatırlatma",
      body: "${todo.title} (${todo.priority.name.toUpperCase()})",
      scheduledTime: todo.deadline,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Todo List")),
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
                            if (val != null)
                              // ignore: curly_braces_in_flow_control_structures
                              setState(() => _selectedPriority = val);
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
                          child: ListTile(
                            title: Text(todo.title),
                            subtitle: Text(
                              "Deadline: ${DateFormat('dd/MM/yyyy HH:mm').format(todo.deadline)}\n"
                              "Önem: ${todo.priority.name.toUpperCase()}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  setState(() => _todos.removeAt(index)),
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
