import 'package:Power_Focus/pages/calendar_page.dart';
import 'package:Power_Focus/pages/deleted_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'main_layout.dart';// MainLayoutをインポート

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
      title: 'PowerFocus',
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/calendar': (context) => const CalendarPage(),
        '/deleted_tasks': (context) => const DeletedTasksPage(),
      },
    );
  }
}
