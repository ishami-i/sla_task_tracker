import 'package:flutter/material.dart';
import '../models/task.dart';

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
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              task.description ?? 'No description',
            ),

            const SizedBox(height: 16),

            Text('Priority: ${task.priority}'),

            const SizedBox(height: 8),

            Text('Deadline: ${task.deadline}'),

            const SizedBox(height: 8),

            Text('Status: ${task.status}'),

            const SizedBox(height: 8),

            Text('SLA Status: ${task.slaStatus}'),

            const SizedBox(height: 8),

            Text(
              'Assigned User ID: ${task.assignedTo ?? 'Not assigned'}',
            ),
          ],
        ),
      ),
    );
  }
}