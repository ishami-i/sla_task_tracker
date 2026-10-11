import 'package:flutter/material.dart';
import '../logic/sla_calculator.dart';
import '../models/task.dart';
import '../screens/taskStatistic_page.dart';
import '../services/database_helper.dart';
import '../utils/app_colors.dart';
import 'createTask_form.dart';
import 'sla_chip.dart';

class TaskDetails extends StatefulWidget {
  final Task task;

  const TaskDetails({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late Task _currentTask;
  String? _assigneeName;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadAssignee();
  }

  Future<void> _loadAssignee() async {
    final id = _currentTask.assignedTo;
    if (id == null) {
      if (_assigneeName != null) setState(() => _assigneeName = null);
      return;
    }
    try {
      final user = await DatabaseHelper.instance.getUserById(id);
      if (mounted) setState(() => _assigneeName = user?.name);
    } catch (e) {
      debugPrint('Could not load assignee: $e');
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskForm(task: _currentTask),
      ),
    );

    if (result == true && mounted) {
      if (_currentTask.id != null) {
        final updated =
            await DatabaseHelper.instance.getTaskById(_currentTask.id!);
        if (updated != null && mounted) {
          setState(() {
            _currentTask = updated;
          });
          _loadAssignee();
        }
      }
    }
  }

  void _navigateToVisualize() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskStatisticPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Task',
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Visualize Task',
            onPressed: _navigateToVisualize,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.secondary),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTask.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentTask.description ?? 'No description provided.',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.secondary),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.flag,
                      label: 'Priority',
                      value: _currentTask.priority,
                      valueColor: AppColors.primary,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Deadline',
                      value: _currentTask.deadline,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.task_alt,
                      label: 'Status',
                      value: _currentTask.status,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'SLA Status',
                      trailing: SlaChip(
                        status: calculateSlaStatus(
                          _currentTask,
                          now: DateTime.now(),
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Assigned To',
                      value: _currentTask.assignedTo == null
                          ? 'Not assigned'
                          : (_assigneeName ?? 'Loading…'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _navigateToEdit,
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    label: const Text(
                      'Edit Task',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToVisualize,
                    icon: const Icon(Icons.bar_chart, color: Colors.white),
                    label: const Text(
                      'Visualize Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String value = '',
    Color? valueColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          trailing ??
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.text,
                ),
              ),
        ],
      ),
    );
  }
}
