import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/presentation/pages/todomain_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'todo_channel',
      channelName: 'Todo Notifications',
      channelDescription: 'Deadline hatırlatmaları',
      defaultColor: Colors.blue,
      importance: NotificationImportance.High,
    ),
  ]);
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),

      body: TodoPage(),
    );
  }
}
