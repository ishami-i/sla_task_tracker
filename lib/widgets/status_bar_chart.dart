import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../utils/app_colors.dart';

class StatusBarChart extends StatelessWidget {
  final Map<SlaStatus, int> counts;

  static const List<SlaStatus> order = [
    SlaStatus.onTrack,
    SlaStatus.atRisk,
    SlaStatus.overdue,
    SlaStatus.completed,
  ];
  static const double maxBarHeight = 120;

  const StatusBarChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.values.fold<int>(0, math.max);

    return SizedBox(
      height: maxBarHeight + 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < order.length; i++)
            Expanded(
              child: _Bar(
                index: i,
                status: order[i],
                count: counts[order[i]] ?? 0,
                maxCount: maxCount,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int index;
  final SlaStatus status;
  final int count;
  final int maxCount;

  static const _growMs = 700;
  static const _staggerMs = 120;

  const _Bar({
    required this.index,
    required this.status,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final delayMs = index * _staggerMs;
    final totalMs = _growMs + delayMs;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: count.toDouble()),
      duration: reduceMotion ? Duration.zero : Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, value, _) {
        final fraction = maxCount == 0 ? 0.0 : value / maxCount;
        final barHeight = math.max(fraction * StatusBarChart.maxBarHeight, 4.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${value.round()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: barHeight,
                decoration: BoxDecoration(
                  color: status.barColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        );
      },
    );
  }
}