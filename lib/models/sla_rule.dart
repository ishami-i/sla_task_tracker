import 'sla_status.dart';

class SlaRule {
  final int order;
  final SlaStatus status;
  final String description;

  const SlaRule({
    required this.order,
    required this.status,
    required this.description,
  });
}

const int highPriorityExtraHours = 24;

List<SlaRule> buildSlaRules({
  required int atRiskHours,
  required bool highPriorityBoost,
}) {
  final atRiskText = highPriorityBoost
      ? 'Not done and under $atRiskHours h left - or under ${atRiskHours + highPriorityExtraHours} h for High priority.'
      : 'Not done and under $atRiskHours h left.';

  return [
    const SlaRule(
      order: 1,
      status: SlaStatus.completed,
      description: 'Status is Done.',
    ),
    const SlaRule(
      order: 2,
      status: SlaStatus.overdue,
      description: 'Not done and the deadline has passed.',
    ),
    SlaRule(
      order: 3,
      status: SlaStatus.atRisk,
      description: atRiskText,
    ),
    const SlaRule(
      order: 4,
      status: SlaStatus.onTrack,
      description: 'Everything else.',
    ),
  ];
}