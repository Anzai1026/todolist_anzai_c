import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Box todoBox = Hive.box('todoBox');
  DateTime _selectedDay = DateTime.now();
  late List<Map<String, dynamic>> _tasksForSelectedDay;
  Map<DateTime, int> _tasksCountPerDay = {};

  @override
  void initState() {
    super.initState();
    _debugPrintHiveTasks(); // Add this line for debugging
    _loadTasksForSelectedDay();
    _loadTasksCountPerDay();
  }

  void _debugPrintHiveTasks() {
    final tasks = todoBox.values.map((task) {
      if (task is Map) {
        return Map<String, dynamic>.from(task);
      }
      return null;
    }).where((task) => task != null).toList();

    print('Tasks in Hive: $tasks');
  }

  void _loadTasksForSelectedDay() {
    setState(() {
      _tasksForSelectedDay = todoBox.values
          .where((task) {
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
          final dateString = taskMap['date'] ?? '';
          print('Parsing date: $dateString'); // Debug output
          final taskDate = DateTime.tryParse(dateString);
          if (taskDate != null) {
            final dateKey = DateTime(taskDate.year, taskDate.month, taskDate.day);
            _tasksCountPerDay[dateKey] = (_tasksCountPerDay[dateKey] ?? 0) + 1;
          } else {
            print('Failed to parse date: $dateString'); // Debug output
          }
        }
      });
      print('Tasks Count Per Day: $_tasksCountPerDay'); // Debug output
    });
  }

  Color _getDayColor(DateTime day) {
    final taskCount = _tasksCountPerDay[day] ?? 0;
    final baseColor = Colors.blue;

    if (taskCount == 0) {
      return Colors.transparent;
    }

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
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: Colors.white,
            child: TableCalendar(
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
                  final hasTasks = _tasksCountPerDay.containsKey(day);
                  print('Day: $day, Has Tasks: $hasTasks'); // Debug output
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: hasTasks ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hasTasks)
                        Positioned(
                          bottom: 5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                leftChevronIcon: Icon(Icons.arrow_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.arrow_right, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: _tasksForSelectedDay.length,
                itemBuilder: (context, index) {
                  final task = _tasksForSelectedDay[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        task['task'] ?? 'No task name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['description'] ?? 'No description',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('${task['date']} ${task['time']}'),
                        ],
                      ),
                      tileColor: Color(task['color'] ?? Colors.grey.value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
