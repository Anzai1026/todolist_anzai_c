import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workout_todo/deleted_tasks_page.dart';
import 'home_page.dart';
import 'calendar_page.dart'; // カレンダーページをインポート

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  await Hive.openBox('deletedTasksBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Todo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
      routes: {
        '/calendar': (context) => const CalendarPage(),
        '/deleted_tasks': (context) => const DeletedTasksPage(),
      },
    );
  }
}
