import 'package:flutter/material.dart';
import '../models/sla_status.dart';

class SlaBadge extends StatelessWidget {
  final SlaStatus status;

  static const _duration = Duration(milliseconds: 300);

  const SlaBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: _duration,
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: status.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: _duration,
            child: Text(
              status.label,
              key: ValueKey(status),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: status.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}