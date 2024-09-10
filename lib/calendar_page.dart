import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Box todoBox = Hive.box('todoBox');
  DateTime _selectedDay = DateTime.now();
  late List<Map<String, dynamic>> _tasksForSelectedDay;
  Map<DateTime, int> _tasksCountPerDay = {}; // Initialize here

  @override
  void initState() {
    super.initState();
    _loadTasksForSelectedDay();
    _loadTasksCountPerDay(); // Ensure this is called
  }

  void _loadTasksForSelectedDay() {
    setState(() {
      _tasksForSelectedDay = todoBox.values
          .where((task) {
        // Check if the task is a Map and has the necessary keys
        if (task is Map && task.containsKey('date')) {
          final taskMap = Map<String, dynamic>.from(task);
          final taskDate = DateTime.tryParse(taskMap['date'] ?? '');
          return taskDate != null &&
              taskDate.year == _selectedDay.year &&
              taskDate.month == _selectedDay.month &&
              taskDate.day == _selectedDay.day;
        }
        return false;
      })
          .map((task) {
        // Convert dynamic to Map<String, dynamic>
        return Map<String, dynamic>.from(task);
      })
          .toList();
    });
  }

  void _loadTasksCountPerDay() {
    setState(() {
      _tasksCountPerDay = {};
      todoBox.values.forEach((task) {
        if (task is Map && task.containsKey('date')) {
          final taskMap = Map<String, dynamic>.from(task);
          final taskDate = DateTime.tryParse(taskMap['date'] ?? '');
          if (taskDate != null) {
            final dateKey = DateTime(taskDate.year, taskDate.month, taskDate.day);
            _tasksCountPerDay[dateKey] = (_tasksCountPerDay[dateKey] ?? 0) + 1;
          }
        }
      });
    });
  }

  Color _getDayColor(DateTime day) {
    final taskCount = _tasksCountPerDay[day] ?? 0;
    // Define a base color
    final baseColor = Colors.blue;

    // Return transparent color if no tasks are present
    if (taskCount == 0) {
      return Colors.transparent;
    }

    // Calculate opacity based on the number of tasks
    final opacity = (0.1 + (0.9 * taskCount / 10)).clamp(0.1, 1.0);

    return baseColor.withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar View',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2101, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _loadTasksForSelectedDay();
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: _getDayColor(day),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: _getDayColor(day) == Colors.transparent
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasksForSelectedDay.length,
              itemBuilder: (context, index) {
                final task = _tasksForSelectedDay[index];
                return ListTile(
                  title: Text(task['task'] ?? 'No task name'),
                  subtitle: Text('${task['date']} ${task['time']}'),
                  tileColor: Color(task['color'] ?? Colors.grey.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
