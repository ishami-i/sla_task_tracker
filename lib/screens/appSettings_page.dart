import 'package:flutter/material.dart';
import '../models/sla_rule.dart';
import '../models/sla_settings.dart';
import '../models/user.dart';
import '../services/settings_storage.dart';
import '../services/user_session.dart';
import '../utils/app_colors.dart';
import '../widgets/error_view.dart';
import '../widgets/preferences_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/sla_rule_tile.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _loading = true;
  String? _error;
  User? _user;
  SlaSettings _settings = const SlaSettings();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await UserSession.loadCurrentUser();
      final settings = await SettingsStorage.loadSlaSettings();
      if (!mounted) return;
      setState(() {
        _user = user;
        _settings = settings;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Settings load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your settings.';
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveSettings() async {
    final ok = await SettingsStorage.saveSlaSettings(_settings);
    if (!ok && mounted) _showSnack('Could not save settings on this device');
  }

  void _onAtRiskHoursChanged(int hours) {
    setState(() => _settings = _settings.copyWith(atRiskHours: hours));
  }

  void _onHighPriorityBoostChanged(bool value) {
    setState(() => _settings = _settings.copyWith(highPriorityBoost: value));
    _saveSettings();
  }

  void _onSwitchUser() {
    _showSnack('Switch users from the Sign In page');
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset SLA settings?'),
        content: const Text(
          'The at-risk window goes back to 48 h and the High-priority warning is turned on.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final ok = await SettingsStorage.resetSlaSettings();
    if (!mounted) return;
    if (!ok) {
      _showSnack('Could not reset settings');
      return;
    }

    final settings = await SettingsStorage.loadSlaSettings();
    if (!mounted) return;
    setState(() => _settings = settings);
    _showSnack('SLA settings reset');
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ],
    );
  }

  Widget _rulesCard(List<SlaRule> rules) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rules.length; i++) ...[
            SlaRuleTile(rule: rules[i]),
            if (i < rules.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(User user) {
    final rules = buildSlaRules(
      atRiskHours: _settings.atRiskHours,
      highPriorityBoost: _settings.highPriorityBoost,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        ProfileCard(
          name: user.name,
          role: user.role,
          onSwitch: _onSwitchUser,
        ),
        const SizedBox(height: 22),
        _sectionTitle(
          'How SLA status is decided',
          subtitle: 'Checked top to bottom — the first rule that matches wins.',
        ),
        const SizedBox(height: 10),
        _rulesCard(rules),
        const SizedBox(height: 22),
        _sectionTitle('Preferences'),
        const SizedBox(height: 10),
        PreferencesCard(
          atRiskHours: _settings.atRiskHours,
          highPriorityBoost: _settings.highPriorityBoost,
          onAtRiskHoursChanged: _onAtRiskHoursChanged,
          onAtRiskHoursChangeEnd: (_) => _saveSettings(),
          onHighPriorityBoostChanged: _onHighPriorityBoostChanged,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _confirmReset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Reset SLA settings'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: Color.fromRGBO(243, 196, 191, 1.0)),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final user = _user;
    if (_error != null || user == null) {
      return ErrorView(
        message: _error ?? 'Could not load your settings.',
        onRetry: () {
          setState(() => _loading = true);
          _load();
        },
      );
    }

    return _buildContent(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: SafeArea(child: _buildBody()),
    );
  }
}