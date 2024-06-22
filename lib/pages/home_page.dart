import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/util/todo_tile.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final todoBox = Hive.box('todoBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        title: const Text('To Do'),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box box, _) {
          List todoList = box.values.toList();
          return ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (BuildContext context, int index) {
              var task = todoList[index];
              return TodoTile(
                taskName: task['task'],
                taskCompleted: task['completed'],
                taskDate: task['date'], // 日付フィールドを追加
                onChanged: (value) => _checkBoxChanged(index, value),
                deleteFunction: (context) => _deleteTask(index),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a new todo item',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: _saveNewTask,
              backgroundColor: Colors.red[100],
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _checkBoxChanged(int index, bool? value) {
    setState(() {
      var task = todoBox.getAt(index);
      task['completed'] = value;
      todoBox.putAt(index, task);
    });
  }

  void _saveNewTask() {
    setState(() {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

      todoBox.add({
        'task': _controller.text,
        'completed': false,
        'date': formattedDate,
      });
      _controller.clear();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      todoBox.deleteAt(index);
    });
  }
}
