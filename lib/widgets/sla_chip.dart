import 'package:flutter/material.dart';

enum SlaStatus { onTrack, atRisk, overdue, completed }

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
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case SlaStatus.onTrack:
        label = 'On Track'; bg = const Color(0xFFD9F5E3); fg = const Color(0xFF1B7F43);
        break;
      case SlaStatus.atRisk:
        label = 'At Risk'; bg = const Color(0xFFFFF0C2); fg = const Color(0xFF9A6A00);
        break;
      case SlaStatus.overdue:
        label = 'Overdue'; bg = const Color(0xFFFFDAD6); fg = const Color(0xFFB3261E);
        break;
      case SlaStatus.completed:
        label = 'Completed'; bg = const Color(0xFFE3E6EB); fg = const Color(0xFF4A5568);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}