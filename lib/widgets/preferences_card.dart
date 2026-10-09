import 'package:flutter/material.dart';
import '../models/sla_rule.dart';
import '../models/sla_settings.dart';
import '../utils/app_colors.dart';

class PreferencesCard extends StatelessWidget {
  final int atRiskHours;
  final bool highPriorityBoost;
  final ValueChanged<int> onAtRiskHoursChanged;
  final ValueChanged<int> onAtRiskHoursChangeEnd;
  final ValueChanged<bool> onHighPriorityBoostChanged;

  const PreferencesCard({
    super.key,
    required this.atRiskHours,
    required this.highPriorityBoost,
    required this.onAtRiskHoursChanged,
    required this.onAtRiskHoursChangeEnd,
    required this.onHighPriorityBoostChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'At-risk window',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                '$atRiskHours h',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Unfinished tasks due within this window are flagged At Risk.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          Slider(
            value: atRiskHours.toDouble(),
            min: minAtRiskHours.toDouble(),
            max: maxAtRiskHours.toDouble(),
            divisions: (maxAtRiskHours - minAtRiskHours) ~/ atRiskStepHours,
            label: '$atRiskHours h',
            activeColor: AppColors.accent,
            inactiveColor: AppColors.divider,
            onChanged: (value) => onAtRiskHoursChanged(value.round()),
            onChangeEnd: (value) => onAtRiskHoursChangeEnd(value.round()),
          ),
          const Divider(height: 1, color: AppColors.divider),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: highPriorityBoost,
            onChanged: onHighPriorityBoostChanged,
            title: const Text(
              'Extra warning for High priority',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            subtitle: const Text(
              'High-priority tasks turn At Risk $highPriorityExtraHours h earlier.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}