import 'package:Power_Focus/pages/calendar_page.dart';
import 'package:Power_Focus/pages/deleted_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'main_layout.dart'; // MainLayoutをインポート
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: FirebaseAuth.instance.currentUser == null
          ? LoginPage()
          : const MainLayout(), // ユーザーがログインしていない場合はLoginPageを表示
      debugShowCheckedModeBanner: false,
      routes: {
        '/calendar': (context) => const CalendarPage(),
        '/deleted_tasks': (context) => const DeletedTasksPage(),
      },
    );
  }
}
