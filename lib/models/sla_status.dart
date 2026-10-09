import 'package:flutter/material.dart';

enum SlaStatus {
  completed('Completed', Color(0xFFDDDBFF), Color(0xFF2F28C9), Color(0xFF443DFF)),
  overdue('Overdue', Color(0xFFFBE3E1), Color(0xFFA3261B), Color(0xFFC8352A)),
  atRisk('At Risk', Color(0xFFFCEFD6), Color(0xFF8A4B00), Color(0xFFD98A00)),
  onTrack('On Track', Color(0xFFE2F2E4), Color(0xFF0B5D1E), Color(0xFF1E8A3A));

  final String label;
  final Color background;
  final Color foreground;
  final Color barColor;

  const SlaStatus(this.label, this.background, this.foreground, this.barColor);
}