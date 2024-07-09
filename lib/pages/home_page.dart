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
  bool _showDeletedTasks = false; // To track the state of deleted tasks view
  List<Map> _deletedTasks = []; // To keep track of deleted tasks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        title: const Text(
          'Workout Todo',
        style: TextStyle(
            fontSize: 30,fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black45,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showDeletedTasks = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                      'Current Tasks',
                  style: TextStyle(
                    color: Colors.white
                  ),),
                ),
                style: ElevatedButton.styleFrom(fixedSize: Size(200, 50),
                  backgroundColor: Colors.blue, //押したときの色！！
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDeletedTasks = true;
                    });
                  },
                  child: Text(
                      'Deleted Tasks',
                  style: TextStyle(
                    color: Colors.white
                  ),),
                  style: ElevatedButton.styleFrom(fixedSize: Size(200, 50),
                    backgroundColor: Colors.red, //押したときの色！！
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: todoBox.listenable(),
              builder: (context, Box box, _) {
                List todoList = _showDeletedTasks ? _deletedTasks : box.values.toList();
                return ListView.builder(
                  itemCount: todoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var task = todoList[index];
                    return TodoTile(
                      taskName: task['task'],
                      taskCompleted: task['completed'],
                      taskDate: task['date'],
                      onChanged: _showDeletedTasks ? null : (value) => _checkBoxChanged(index, value),
                      deleteFunction: _showDeletedTasks ? null : (context) => _deleteTask(index),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
                      borderSide: const BorderSide(color: Colors.grey),
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
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
              shape: CircleBorder(),
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
      var task = todoBox.getAt(index);
      _deletedTasks.add(task);
      todoBox.deleteAt(index);
    });
  }
}
