import 'package:flutter/material.dart';
import '../models/sla_status.dart';

/// SLA rules: completed > overdue (past deadline) > at risk (due within 2 days) > on track
SlaStatus slaFor(DateTime dueDate, bool completed) {
  if (completed) return SlaStatus.completed;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  if (due.isBefore(today)) return SlaStatus.overdue;
  if (due.difference(today).inDays <= 2) return SlaStatus.atRisk;
  return SlaStatus.onTrack;
}

class SlaChip extends StatelessWidget {
  final SlaStatus status;
  const SlaChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
