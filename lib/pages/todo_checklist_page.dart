import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../custom_app_bar.dart';
import '../routes.dart';
import '../util/todo_tile.dart';

class TodoChecklistPage extends StatelessWidget {
  const TodoChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todoBox = Hive.box('todoBox');

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: const CustomAppBar(title: 'PowerFocus'), // Using CustomAppBar
      body: Padding( // Added padding for better spacing
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
          valueListenable: todoBox.listenable(),
          builder: (context, Box box, _) {
            List<Map<String, dynamic>> checklist = box.values
                .where((task) => task['completed'] == true)
                .map((task) => Map<String, dynamic>.from(task as Map))
                .toList();

            if (checklist.isEmpty) {
              return const Center(
                child: Text(
                  'No completed tasks',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              );
            }

            return ListView.separated( // Added separator for better readability
              itemCount: checklist.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black54, // Divider between tasks
                thickness: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                var task = checklist[index];
                return Dismissible(
                  key: ValueKey(task['id'] ?? UniqueKey()),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final result = await _showEditDialog(context, index);
                      return result;
                    } else if (direction == DismissDirection.startToEnd) {
                      final result = await _confirmDelete(context, index);
                      return result;
                    }
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

  Future<bool> _confirmDelete(BuildContext context, int index) async {
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
    )) ?? false;
  }

  Future<bool> _showEditDialog(BuildContext context, int index) async {
    final task = Hive.box('todoBox').getAt(index);
    final titleController = TextEditingController(text: task['task']);
    final descriptionController = TextEditingController(text: task['description']);
    final categoryController = TextEditingController(text: task['category']);

    return (await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Task title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Task description'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(hintText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Hive.box('todoBox').putAt(index, {
                'task': titleController.text,
                'description': descriptionController.text,
                'category': categoryController.text,
                'completed': task['completed'],
                'date': task['date'],
                'time': task['time'],
                'color': task['color'],
              });
              Navigator.of(context).pop(true);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    )) ?? false;
  }

  void _checkBoxChanged(BuildContext context, int index, bool? value) {
    final box = Hive.box('todoBox');
    var task = box.getAt(index);
    if (value == true) {
      box.deleteAt(index);
      Navigator.pushReplacement(
        context,
        NoAnimationPageRoute(builder: (_) => const TodoChecklistPage()),
      );
    } else {
      task['completed'] = value;
      box.putAt(index, task);
    }
  }

  void _deleteTask(int index) {
    final task = Hive.box('todoBox').getAt(index);
    Hive.box('deletedTasksBox').add(task);
    Hive.box('todoBox').deleteAt(index);
  }
}
