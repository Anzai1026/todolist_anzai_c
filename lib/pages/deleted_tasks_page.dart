import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeletedTasksPage extends StatelessWidget {
  const DeletedTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deletedTasksBox = Hive.box('deletedTasksBox'); // 削除タスク用ボックス

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deleted Tasks',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: deletedTasksBox.listenable(),
        builder: (context, Box box, _) {
          List<Map<String, dynamic>> deletedTasksList = box.values.map((task) {
            return Map<String, dynamic>.from(task as Map);
          }).toList();

          return ListView.builder(
            itemCount: deletedTasksList.length,
            itemBuilder: (context, index) {
              var task = deletedTasksList[index];
              return ListTile(
                title: Text(task['task'] ?? 'No task name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task['description'] != null)
                      Text('Description: ${task['description']}'),
                    Text('Date: ${task['date']} Time: ${task['time']}'),
                  ],
                ),
                tileColor: Color(task['color'] ?? Colors.grey.value),
              );
            },
          );
        },
      ),
    );
  }
}
