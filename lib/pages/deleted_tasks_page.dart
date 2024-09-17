import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeletedTasksPage extends StatelessWidget {
  const DeletedTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deletedTasksBox = Hive.box('deletedTasksBox');

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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: deletedTasksBox.listenable(),
        builder: (context, Box box, _) {
          List<Map<String, dynamic>> deletedTasksList = box.values.map((task) {
            return Map<String, dynamic>.from(task as Map);
          }).toList();

          if (deletedTasksList.isEmpty) {
            return const Center(
              child: Text('No deleted tasks.'),
            );
          }

          return ListView.builder(
            itemCount: deletedTasksList.length,
            itemBuilder: (context, index) {
              var task = deletedTasksList[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['task'] ?? 'No task name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (task['description'] != null)
                        Text('Description: ${task['description']}'),
                      const SizedBox(height: 4),
                      Text('Date: ${task['date']} Time: ${task['time']}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore,  color: Colors.blue),
                            onPressed: () {
                              _restoreTask(deletedTasksBox, index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,  color: Colors.red),
                            onPressed: () {
                              _deleteTaskPermanently(deletedTasksBox, index);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Method to restore task
  void _restoreTask(Box deletedTasksBox, int index) {
    var task = deletedTasksBox.getAt(index);
    final todoBox = Hive.box('todoBox'); // Access the todoBox to restore

    // Add the task back to the todoBox
    todoBox.add(task);

    // Remove from deletedTasksBox
    deletedTasksBox.deleteAt(index);
  }

  // Method to delete task permanently
  void _deleteTaskPermanently(Box deletedTasksBox, int index) {
    // Permanently delete the task from deletedTasksBox
    deletedTasksBox.deleteAt(index);
  }
}
