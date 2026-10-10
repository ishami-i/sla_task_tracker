const int minAtRiskHours = 12;
const int maxAtRiskHours = 96;
const int atRiskStepHours = 12;

class SlaSettings {
  final int atRiskHours;
  final bool highPriorityBoost;

  const SlaSettings({
    this.atRiskHours = 48,
    this.highPriorityBoost = true,
  });

  SlaSettings copyWith({int? atRiskHours, bool? highPriorityBoost}) {
    return SlaSettings(
      atRiskHours: atRiskHours ?? this.atRiskHours,
      highPriorityBoost: highPriorityBoost ?? this.highPriorityBoost,
    );
  }
}