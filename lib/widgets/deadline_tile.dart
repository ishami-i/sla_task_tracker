import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../utils/app_colors.dart';
import '../utils/date_format.dart';
import 'sla_badge.dart';

class DeadlineTile extends StatelessWidget {
  final String title;
  final DateTime deadline;
  final SlaStatus sla;
  final DateTime now;

  const DeadlineTile({
    super.key,
    required this.title,
    required this.deadline,
    required this.sla,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final timeLeft = formatTimeLeft(deadline.difference(now));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_outlined, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatShortDate(deadline)} · $timeLeft',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SlaBadge(status: sla),
        ],
      ),
    );
  }
}