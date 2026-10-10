import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sla_settings.dart';

class SettingsStorage {
  SettingsStorage._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const _kAtRiskHours = 'sla_at_risk_hours';
  static const _kHighPriorityBoost = 'sla_high_priority_boost';

  static Future<SlaSettings> loadSlaSettings() async {
    const defaults = SlaSettings();
    try {
      final hours = await _prefs.getInt(_kAtRiskHours);
      final boost = await _prefs.getBool(_kHighPriorityBoost);
      return SlaSettings(
        atRiskHours: (hours ?? defaults.atRiskHours)
            .clamp(minAtRiskHours, maxAtRiskHours),
        highPriorityBoost: boost ?? defaults.highPriorityBoost,
      );
    } catch (e) {
      debugPrint('loadSlaSettings failed: $e');
      return defaults;
    }
  }

  static Future<bool> saveSlaSettings(SlaSettings settings) async {
    try {
      await _prefs.setInt(_kAtRiskHours, settings.atRiskHours);
      await _prefs.setBool(_kHighPriorityBoost, settings.highPriorityBoost);
      return true;
    } catch (e) {
      debugPrint('saveSlaSettings failed: $e');
      return false;
    }
  }

  static Future<bool> resetSlaSettings() async {
    try {
      await _prefs.remove(_kAtRiskHours);
      await _prefs.remove(_kHighPriorityBoost);
      return true;
    } catch (e) {
      debugPrint('resetSlaSettings failed: $e');
      return false;
    }
  }
}