import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../custom_app_bar.dart';
import '../util/todo_tile.dart';

class TodoChecklistPage extends StatefulWidget {
  const TodoChecklistPage({super.key});

  @override
  State<TodoChecklistPage> createState() => _TodoChecklistPageState();
}

class _TodoChecklistPageState extends State<TodoChecklistPage> {
  final todoBox = Hive.box('todoBox');
  final deletedTasksBox = Hive.box('deletedTasksBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: CustomAppBar(title: 'PowerFocus'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: todoBox.listenable(),
          builder: (context, Box box, _) {
            List<Map<String, dynamic>> checklist = box.values
                .where((task) => task['completed'] == true) // 完了タスクのみ
                .map((task) {
              return Map<String, dynamic>.from(task as Map);
            }).toList();

            return ListView.separated(
              itemCount: checklist.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black54,
                thickness: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                var task = checklist[index];
                return Dismissible(
                  key: ValueKey(task['id'] ?? UniqueKey()), // Ensure unique key
                  background: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    child: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  direction: DismissDirection.startToEnd, // Allow only left swipe
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Handle delete
                      final result = await _confirmDelete(index);
                      return result;
                    }
                    // Return false for any other direction
                    return false;
                  },
                  child: TodoTile(
                    taskName: task['task'] ?? 'No task name',
                    taskDescription: task['description'] ?? '',
                    taskCompleted: task['completed'] ?? false,
                    taskDate: task['date'] ?? 'No date',
                    taskTime: task['time'] ?? 'No time',
                    taskColor: Color(task['color'] ?? Colors.grey.value),
                    taskCategory: task['category'] ?? 'General',
                    onChanged: (value) => _checkBoxChanged(context, index, value),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(int index) async {
    return (await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteTask(index);
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    )) ?? false; // Ensure that the return type is bool
  }

  void _checkBoxChanged(BuildContext context, int index, bool? value) {
    final box = Hive.box('todoBox');
    var task = box.getAt(index);

    setState(() {
      // Update the completion status
      task['completed'] = value;

      // Update the Hive box with the modified task
      box.putAt(index, task);
    });
  }

  void _deleteTask(int index) {
    final task = todoBox.getAt(index);
    deletedTasksBox.add(task); // Add task to the deleted tasks box
    todoBox.deleteAt(index); // Delete the task from the main box
  }
}
