import '../logic/sla_calculator.dart';
import '../models/task.dart';
import '../utils/date_format.dart';

List<Task> buildSampleTasks(DateTime now, {List<int> assigneeIds = const []}) {
  var next = 0;

  int? nextAssignee() {
    if (assigneeIds.isEmpty) return null;
    return assigneeIds[next++ % assigneeIds.length];
  }

  Task task(
    String title,
    String description,
    String priority,
    Duration dueIn,
    String status,
  ) {
    final deadline = formatDeadlineForStorage(now.add(dueIn));
    final sla = calculateSla(
      status: status,
      priority: priority,
      deadline: deadline,
      now: now,
    );
    return Task(
      title: title,
      description: description,
      assignedTo: nextAssignee(),
      priority: priority,
      deadline: deadline,
      status: status,
      slaStatus: sla.label,
    );
  }

  return [
    task('Implement Local Storage', 'Save tasks and users with SQLite.', 'Medium', const Duration(hours: 30), 'In Progress'),
    task('Payment confirmation screen', 'Screen shown after a transfer succeeds.', 'High', const Duration(hours: 60), 'To-do'),
    task('API docs for transfers', 'Document the transfer endpoints.', 'Medium', const Duration(hours: 20), 'In Progress'),
    task('Fix login token refresh', 'Users are logged out after one hour.', 'High', const Duration(days: -2), 'In Progress'),
    task('KYC upload test cases', 'Write test cases for document upload.', 'Medium', const Duration(days: -1), 'To-do'),
    task('Splash screen animation', 'Animate the logo on app start.', 'Low', const Duration(days: -4), 'Completed'),
    task('Set up project repository', 'Create the repo and branches.', 'Medium', const Duration(days: -6), 'Completed'),
    task('Test Application', 'Run the full app on an emulator.', 'Medium', const Duration(days: 5), 'To-do'),
    task('Prepare Demo', 'Plan the 10-15 minute demo video.', 'High', const Duration(days: 8), 'To-do'),
    task('Onboarding illustrations', 'Draw three onboarding images.', 'Low', const Duration(days: 7), 'In Progress'),
    task('Rate-limit transfer endpoint', 'Limit repeated transfer requests.', 'Low', const Duration(hours: 60), 'To-do'),
    task('Write technical report', 'Challenges and solutions, 2-4 pages.', 'Medium', const Duration(days: 10), 'To-do'),
  ];
}
