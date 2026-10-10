import 'package:flutter/material.dart';
import '../data/sample_tasks.dart';
import '../logic/sla_calculator.dart';
import '../models/sla_rule.dart';
import '../models/sla_settings.dart';
import '../models/sla_status.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/settings_storage.dart';
import '../utils/app_colors.dart';
import '../widgets/deadline_tile.dart';
import '../widgets/error_view.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/status_bar_chart.dart';

class TaskStatisticPage extends StatefulWidget {
  static const routeName = '/statistics';

  const TaskStatisticPage({super.key});

  @override
  State<TaskStatisticPage> createState() => _TaskStatisticPageState();
}

class _UpcomingTask {
  final Task task;
  final DateTime deadline;

  const _UpcomingTask(this.task, this.deadline);
}

class _TaskStatisticPageState extends State<TaskStatisticPage> {
  bool _loading = true;
  bool _addingSamples = false;
  String? _error;
  DateTime _now = DateTime.now();
  List<Task> _tasks = [];
  SlaSettings _settings = const SlaSettings();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tasks = await DatabaseHelper.instance.getTasks();
      final settings = await SettingsStorage.loadSlaSettings();
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _tasks = tasks;
        _settings = settings;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Statistics load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load tasks from the database.';
      });
    }
  }

  Future<void> _addSampleTasks() async {
    setState(() => _addingSamples = true);
    try {
      for (final task in buildSampleTasks(DateTime.now())) {
        await DatabaseHelper.instance.insertTask(task);
      }
      await _load();
    } catch (e) {
      debugPrint('Adding sample tasks failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add sample tasks')),
        );
      }
    } finally {
      if (mounted) setState(() => _addingSamples = false);
    }
  }

  SlaStatus _slaOf(Task task) {
    return calculateSlaStatus(
      task,
      now: _now,
      atRiskHours: _settings.atRiskHours,
      highPriorityBoost: _settings.highPriorityBoost,
    );
  }

  Map<SlaStatus, int> _countByStatus() {
    final counts = {for (final s in SlaStatus.values) s: 0};
    for (final task in _tasks) {
      final status = _slaOf(task);
      counts[status] = counts[status]! + 1;
    }
    return counts;
  }

  List<_UpcomingTask> _upcomingDeadlines({int limit = 3}) {
    final upcoming = <_UpcomingTask>[];
    for (final task in _tasks) {
      if (isTaskDone(task.status)) continue;
      final deadline = parseDeadline(task.deadline);
      if (deadline == null || !deadline.isAfter(_now)) continue;
      upcoming.add(_UpcomingTask(task, deadline));
    }
    upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));
    return upcoming.take(limit).toList();
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildEmptyState() {
    return FadeSlideIn(
      child: _card(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.insights_outlined, size: 44, color: AppColors.accent),
            const SizedBox(height: 12),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create a task, or add sample tasks to see the statistics.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _addingSamples ? null : _addSampleTasks,
              icon: _addingSamples
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_add_rounded),
              label: const Text('Add sample tasks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final counts = _countByStatus();
    final completed = counts[SlaStatus.completed]!;
    final percentDone =
        _tasks.isEmpty ? 0 : (completed * 100 / _tasks.length).round();
    final upcoming = _upcomingDeadlines();
    final windowText = _settings.highPriorityBoost
        ? 'At-risk window: ${_settings.atRiskHours} h (+$highPriorityExtraHours h for High)'
        : 'At-risk window: ${_settings.atRiskHours} h';

    return Column(
      children: [
        FadeSlideIn(
          child: _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Task Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Text(
                      '${_tasks.length} tasks · $percentDone% done',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  windowText,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                StatusBarChart(counts: counts),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delay: const Duration(milliseconds: 150),
          child: _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Deadlines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                if (upcoming.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Nothing due — all caught up.',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ),
                for (var i = 0; i < upcoming.length; i++) ...[
                  FadeSlideIn(
                    delay: Duration(milliseconds: 300 + i * 90),
                    offsetY: 12,
                    child: DeadlineTile(
                      title: upcoming[i].task.title,
                      deadline: upcoming[i].deadline,
                      sla: _slaOf(upcoming[i].task),
                      now: _now,
                    ),
                  ),
                  if (i < upcoming.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final error = _error;
    if (error != null) {
      return ErrorView(
        message: error,
        onRetry: () {
          setState(() => _loading = true);
          _load();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _tasks.isEmpty ? _buildEmptyState() : _buildStatistics(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Statistics')),
      body: SafeArea(child: _buildBody()),
    );
  }
}