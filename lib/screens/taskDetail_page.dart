import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/taskDetails.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({
    super.key,
    required this.task,
  });
  @override
  Widget build(BuildContext context) {
    return TaskDetails(task: task);
  }
}
