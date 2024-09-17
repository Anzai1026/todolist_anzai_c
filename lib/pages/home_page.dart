import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../custom_app_bar.dart';
import '../util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final todoBox = Hive.box('todoBox');
  final deletedTasksBox = Hive.box('deletedTasksBox');
  Color _selectedColor = Colors.grey; // Default color
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'General';

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
            // Filter out completed tasks and sort by creation date (newest first)
            List<Map<String, dynamic>> todoList = box.values
                .where((task) => task['completed'] == false) // Show only unchecked tasks
                .map((task) {
              return Map<String, dynamic>.from(task as Map);
            }).toList();

            // Sort tasks by creation date in descending order
            todoList.sort((a, b) {
              final aDate = a['createdAt'] as String?;
              final bDate = b['createdAt'] as String?;
              // Handle null values by defaulting to a very old date
              return (bDate ?? '0000-01-01T00:00:00.000Z')
                  .compareTo(aDate ?? '0000-01-01T00:00:00.000Z');
            });

            return ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (BuildContext context, int index) {
                var task = todoList[index];
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
                  secondaryBackground: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    child: Container(
                      color: Colors.blue,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Handle edit
                      final result = await _showEditDialog(index);
                      return result;
                    } else if (direction == DismissDirection.startToEnd) {
                      // Handle delete
                      final result = await _confirmDelete(index);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
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

  Future<bool> _showEditDialog(int index) async {
    final task = todoBox.getAt(index);
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
              setState(() {
                todoBox.putAt(index, {
                  'task': titleController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'completed': task['completed'],
                  'date': task['date'],
                  'time': task['time'],
                  'color': task['color'],
                  'createdAt': task['createdAt'], // Ensure creation date is preserved
                });
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
    )) ?? false; // Ensure that the return type is bool
  }

  void _checkBoxChanged(BuildContext context, int index, bool? value) {
    final box = Hive.box('todoBox');
    var task = box.getAt(index);

    // Update completion status
    task['completed'] = value;

    // Update Hive data
    box.putAt(index, task);
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();

    // 1. Title, description, and category input
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Task Details'),
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );

    // 2. Color selection
    Color? color = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a color'),
          content: Row(
            children: [
              _buildColorOption(Colors.red.withOpacity(0.4)),
              const SizedBox(width: 10),
              _buildColorOption(Colors.blue.withOpacity(0.4)),
              const SizedBox(width: 10),
              _buildColorOption(Colors.yellow.withOpacity(0.4)),
              const SizedBox(width: 10),
              _buildColorOption(Colors.black.withOpacity(0.4)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedColor);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (color != null) {
      _selectedColor = color;
    }

    // 3. Date selection
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != _selectedDate) {
      _selectedDate = selectedDate;
    }

    // 4. Time selection
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (selectedTime != null && selectedTime != _selectedTime) {
      _selectedTime = selectedTime;
    }

    // Save the new task
    final task = {
      'task': titleController.text,
      'description': descriptionController.text,
      'completed': false,
      'date': '${_selectedDate.toLocal()}'.split(' ')[0],
      'time': '${_selectedTime.format(context)}',
      'color': _selectedColor.value,
      'category': categoryController.text,
      'createdAt': DateTime.now().toIso8601String(), // Add creation date
    };

    todoBox.add(task);
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        color: color,
        child: _selectedColor == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  Future<void> _deleteTask(int index) async {
    final task = todoBox.getAt(index);
    await deletedTasksBox.add(task);
    todoBox.deleteAt(index);
  }
}
