import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/assignment_model.dart';

class AssignmentProvider with ChangeNotifier {
  static const String _boxName = 'assignmentsBox';
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  List<Assignment> _assignments = [];

  // Getters with automatic sorting by earliest dueDate first
  List<Assignment> get assignments {
    final list = [..._assignments];
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  List<Assignment> get pendingAssignments =>
      assignments.where((a) => !a.isCompleted).toList();

  List<Assignment> get completedAssignments =>
      assignments.where((a) => a.isCompleted).toList();

  // 1. INITIALIZATION: Hive, Notifications, and Timezones
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    await loadAssignments();
  }

  // 2. LOAD
  Future<void> loadAssignments() async {
    final box = await Hive.openBox<Assignment>(_boxName);
    _assignments = box.values.toList();
    notifyListeners();
  }

  // 3. ADD
  Future<void> addAssignment(Assignment assignment) async {
    final box = Hive.box<Assignment>(_boxName);
    await box.put(assignment.id, assignment);
    _assignments.add(assignment);

    schedule24HourNotification(assignment);
    notifyListeners();
  }

  // 4. TOGGLE COMPLETION
  Future<void> toggleCompletion(Assignment assignment) async {
    assignment.isCompleted = !assignment.isCompleted;
    await assignment.save();

    if (assignment.isCompleted) {
      await _notificationsPlugin.cancel(assignment.id.hashCode);
    } else {
      schedule24HourNotification(assignment);
    }
    notifyListeners();
  }

  // 5. DELETE
  Future<void> deleteAssignment(Assignment assignment) async {
    await _notificationsPlugin.cancel(assignment.id.hashCode);
    await assignment.delete();
    _assignments.removeWhere((a) => a.id == assignment.id);
    notifyListeners();
  }

  // 6. NOTIFICATION ENGINE: 24-Hour Reminder
  Future<void> schedule24HourNotification(Assignment assignment) async {
    if (assignment.isCompleted) return;

    final scheduleTime = assignment.dueDate.subtract(const Duration(hours: 24));

    if (scheduleTime.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        assignment.id.hashCode,
        'Deadline Approaching!',
        'Your assignment "${assignment.title}" is due in 24 hours. Time to wrap it up!',
        tz.TZDateTime.from(scheduleTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'assignment_deadline_channel',
            'Assignment Deadlines',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 7. SUB-TASK MANAGEMENT
  Future<void> toggleSubTask(Assignment assignment, int index) async {
    assignment.subTaskStatus[index] = !assignment.subTaskStatus[index];
    await assignment.save();
    notifyListeners();
  }

  Future<void> addSubTask(Assignment assignment, String subTaskTitle) async {
    assignment.subTasks.add(subTaskTitle);
    assignment.subTaskStatus.add(false);
    await assignment.save();
    notifyListeners();
  }

  // 8. FOCUS SESSION TRACKING
  Future<void> incrementFocusSession(Assignment assignment) async {
    assignment.completedFocusSessions += 1;
    await assignment.save();
    notifyListeners();
  }
}