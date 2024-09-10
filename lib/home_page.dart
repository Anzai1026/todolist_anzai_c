import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final todoBox = Hive.box('todoBox');
  final deletedTasksBox = Hive.box('deletedTasksBox'); // 削除タスク用のボックス
  Color _selectedColor = Colors.grey; // Default color
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'General'; // Default category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: const Text(
          'Workout Todo',
          style: TextStyle(
            fontSize: 35,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/calendar'); // カレンダー画面へ遷移
              },
              icon: const Icon(Icons.calendar_today_outlined),
              color: Colors.white),
          IconButton(
              onPressed: () {
                // 削除タスクの履歴ページへ遷移
                Navigator.pushNamed(context, '/deleted_tasks');
              },
              icon: const Icon(Icons.access_time_outlined),
              color: Colors.white),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box box, _) {
          List<Map<String, dynamic>> todoList = box.values.map((task) {
            return Map<String, dynamic>.from(task as Map);
          }).toList();

          return ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (BuildContext context, int index) {
              var task = todoList[index];
              return Dismissible(
                key: ValueKey(task['id'] ?? UniqueKey()), // Ensure unique key
                background: Container(color: Colors.red, child: Icon(Icons.delete, color: Colors.white)),
                secondaryBackground: Container(color: Colors.blue, child: Icon(Icons.edit, color: Colors.white)),
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
                  onChanged: (value) => _checkBoxChanged(index, value),
                ),
              );
            },
          );
        },
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
          mainAxisSize: MainAxisSize.min, // Ensure the dialog content is sized to fit its children
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

  void _checkBoxChanged(int index, bool? value) {
    setState(() {
      var task = todoBox.getAt(index);
      task['completed'] = value;
      todoBox.putAt(index, task);
    });
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();

    // 1. タイトル、詳細、ジャンルの入力
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

    // 2. 色の選択
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (color != null) {
      // 3. 日付と時間の設定
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });

        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );

        if (pickedTime != null) {
          setState(() {
            _selectedTime = pickedTime;
          });

          DateTime dateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );

          String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          String formattedTime = DateFormat('HH:mm').format(dateTime);

          setState(() {
            todoBox.add({
              'task': titleController.text,
              'description': descriptionController.text,
              'category': categoryController.text,
              'completed': false,
              'date': formattedDate,
              'time': formattedTime,
              'color': color.value,
            });
            _controller.clear();
          });
        }
      }
    }
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
        Navigator.of(context).pop(color);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      todoBox.deleteAt(index);
    });
  }
}
