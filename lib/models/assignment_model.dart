import 'package:hive/hive.dart';

// This line is crucial! It tells Hive to look for the generated file we will make next.
part 'assignment_model.g.dart';

@HiveType(typeId: 0)
class Assignment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  String priority; // 'High', 'Medium', 'Low'

  @HiveField(5)
  String category; // 'Assignment', 'Project', 'Task'

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  List<String> subTasks;

  @HiveField(8)
  List<bool> subTaskStatus;

  @HiveField(9)
  int completedFocusSessions;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
    List<String>? subTasks,
    List<bool>? subTaskStatus,
    this.completedFocusSessions = 0,
  })  : subTasks = subTasks ?? [],
        subTaskStatus = subTaskStatus ?? [];

  // Logic helper: Automatically flags if a task is due within 48 hours
  bool get isUrgent {
    if (isCompleted) return false;
    final difference = dueDate.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 2;
  }

  // Logic helper: Calculates sub-task progress bar percentage (0.0 to 1.0)
  double get progressPercentage {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    int completed = subTaskStatus.where((status) => status == true).length;
    return completed / subTasks.length;
  }
}