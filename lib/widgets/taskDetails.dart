import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';

class TaskDetails extends StatelessWidget {
  final Task task;

  const TaskDetails({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
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
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task.description ?? 'No description provided.',
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
                      value: task.priority,
                      valueColor: AppColors.primary,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Deadline',
                      value: task.deadline,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.task_alt,
                      label: 'Status',
                      value: task.status,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'SLA Status',
                      value: task.slaStatus,
                      valueColor: AppColors.accent,
                    ),
                    const Divider(color: AppColors.secondary),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Assigned User ID',
                      value: task.assignedTo != null
                          ? '${task.assignedTo}'
                          : 'Not assigned',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
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
