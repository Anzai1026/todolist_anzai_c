import 'package:flutter/material.dart';

class TodoTile extends StatelessWidget {
  final String taskName;
  final String taskDescription;
  final bool taskCompleted;
  final String taskDate;
  final String taskTime;
  final Color taskColor;
  final String taskCategory;
  final ValueChanged<bool?> onChanged;

  const TodoTile({
    required this.taskName,
    required this.taskDescription,
    required this.taskCompleted,
    required this.taskDate,
    required this.taskTime,
    required this.taskColor,
    required this.taskCategory,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Checkbox(
          value: taskCompleted,
          onChanged: onChanged,
        ),
        title: Text(
          taskName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: taskColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text('Date: $taskDate'),
            Text('Time: $taskTime'),
            Text('Category: $taskCategory'),
          ],
        ),
      ),
    );
  }
}
