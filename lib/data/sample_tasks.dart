import '../logic/sla_calculator.dart';
import '../models/task.dart';
import '../utils/date_format.dart';

List<Task> buildSampleTasks(DateTime now) {
  Task task(String title, String priority, Duration dueIn, String status) {
    final deadline = formatDeadlineForStorage(now.add(dueIn));
    final sla = calculateSla(
      status: status,
      priority: priority,
      deadline: deadline,
      now: now,
    );
    return Task(
      title: title,
      priority: priority,
      deadline: deadline,
      status: status,
      slaStatus: sla.label,
    );
  }

  return [
    task('Implement Local Storage', 'Medium', const Duration(hours: 30), 'In Progress'),
    task('Payment confirmation screen', 'High', const Duration(hours: 60), 'To Do'),
    task('API docs for transfers', 'Medium', const Duration(hours: 20), 'In Progress'),
    task('Fix login token refresh', 'High', const Duration(days: -2), 'In Progress'),
    task('KYC upload test cases', 'Medium', const Duration(days: -1), 'To Do'),
    task('Splash screen animation', 'Low', const Duration(days: -4), 'Done'),
    task('Set up project repository', 'Medium', const Duration(days: -6), 'Done'),
    task('Test Application', 'Medium', const Duration(days: 5), 'To Do'),
    task('Prepare Demo', 'High', const Duration(days: 8), 'To Do'),
    task('Onboarding illustrations', 'Low', const Duration(days: 7), 'In Progress'),
    task('Rate-limit transfer endpoint', 'Low', const Duration(hours: 60), 'To Do'),
    task('Write technical report', 'Medium', const Duration(days: 10), 'To Do'),
  ];
}