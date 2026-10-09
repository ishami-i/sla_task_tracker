import 'package:flutter/material.dart';
import '../models/sla_rule.dart';
import '../utils/app_colors.dart';
import 'sla_badge.dart';


class SlaRuleTile extends StatelessWidget {
  final SlaRule rule;

  const SlaRuleTile({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${rule.order}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlaBadge(status: rule.status),
                const SizedBox(height: 6),
                Text(
                  rule.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF3A3950),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}