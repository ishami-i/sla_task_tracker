import '../models/sla_rule.dart';
import '../models/sla_status.dart';
import '../models/task.dart';

const Set<String> _doneStatuses = {'done', 'completed', 'complete'};

bool isTaskDone(String status) =>
    _doneStatuses.contains(status.trim().toLowerCase());

bool isHighPriority(String priority) =>
    priority.trim().toLowerCase() == 'high';

DateTime? parseDeadline(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  final parsed = DateTime.tryParse(text);
  if (parsed != null) {
    final hasTime = text.contains(':');
    return hasTime
        ? parsed
        : DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
  }

  final dayFirst = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$').firstMatch(text);
  if (dayFirst != null) {
    return DateTime(
      int.parse(dayFirst[3]!),
      int.parse(dayFirst[2]!),
      int.parse(dayFirst[1]!),
      23,
      59,
      59,
    );
  }

  return null;
}

SlaStatus calculateSla({
  required String status,
  required String priority,
  required String deadline,
  required DateTime now,
  int atRiskHours = 48,
  bool highPriorityBoost = true,
}) {
  if (isTaskDone(status)) return SlaStatus.completed;

  final due = parseDeadline(deadline);
  if (due == null) return SlaStatus.onTrack;

  if (!due.isAfter(now)) return SlaStatus.overdue;

  final extraHours =
      highPriorityBoost && isHighPriority(priority) ? highPriorityExtraHours : 0;
  final minutesLeft = due.difference(now).inMinutes;

  if (minutesLeft < (atRiskHours + extraHours) * 60) return SlaStatus.atRisk;

  return SlaStatus.onTrack;
}

SlaStatus calculateSlaStatus(
  Task task, {
  required DateTime now,
  int atRiskHours = 48,
  bool highPriorityBoost = true,
}) {
  return calculateSla(
    status: task.status,
    priority: task.priority,
    deadline: task.deadline,
    now: now,
    atRiskHours: atRiskHours,
    highPriorityBoost: highPriorityBoost,
  );
}