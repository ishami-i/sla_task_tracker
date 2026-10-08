import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../utils/create_validator.dart';

class CreateTaskForm extends StatefulWidget {
  const CreateTaskForm({super.key});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

// Type alias for backward compatibility
typedef createTaskForm = CreateTaskForm;

class _CreateTaskFormState extends State<CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  int? _selectedUserId;
  String? _selectedPriority;
  String? _selectedStatus = 'To-do';
  DateTime? _selectedDeadlineDate;
  bool _isSubmitting = false;

  late Future<List<User>> _usersFuture;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['To-do', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseHelper.instance.getUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  String _calculateSlaStatus(DateTime? deadlineDate) {
    if (deadlineDate == null) return 'On Time';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadlineDate.year, deadlineDate.month, deadlineDate.day);

    if (deadlineDay.isBefore(today)) {
      return 'Overdue';
    } else if (deadlineDay.difference(today).inDays <= 1) {
      return 'At Risk';
    }
    return 'On Time';
  }

  Future<void> _selectDeadlineDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final DateTime initial = _selectedDeadlineDate ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadlineDate = pickedDate;
        _deadlineController.text =
            "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final slaStatus = _calculateSlaStatus(_selectedDeadlineDate);

      final newTask = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        assignedTo: _selectedUserId,
        priority: _selectedPriority!,
        deadline: _deadlineController.text.trim(),
        status: _selectedStatus!,
        slaStatus: slaStatus,
      );

      await DatabaseHelper.instance.insertTask(newTask);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _deadlineController.clear();
        setState(() {
          _selectedUserId = null;
          _selectedPriority = null;
          _selectedStatus = 'To-do';
          _selectedDeadlineDate = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Task Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: CreateValidator.validateTitle,
            ),

            const SizedBox(height: 16.0),

            // Task Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              validator: CreateValidator.validateDescription,
            ),

            const SizedBox(height: 16.0),

            // Assigned To Dropdown
            FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Error loading users: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'No users found in database',
                    style: TextStyle(color: Colors.orange),
                  );
                } else {
                  return DropdownButtonFormField<int>(
                    value: _selectedUserId,
                    decoration: const InputDecoration(
                      labelText: 'Assigned To',
                      hintText: 'Select User',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: snapshot.data!.map((user) {
                      return DropdownMenuItem<int>(
                        value: user.id,
                        child: Text('${user.name} (${user.role})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                    validator: CreateValidator.validateUser,
                  );
                }
              },
            ),

            const SizedBox(height: 16.0),

            // Deadline Picker
            TextFormField(
              controller: _deadlineController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Deadline',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDeadlineDate(context),
              validator: CreateValidator.validateDeadline,
            ),

            const SizedBox(height: 16.0),

            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                hintText: 'Select Priority',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
              validator: CreateValidator.validatePriority,
            ),

            const SizedBox(height: 16.0),

            // Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                hintText: 'Select Status',
                prefixIcon: Icon(Icons.task_alt),
                border: OutlineInputBorder(),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              validator: CreateValidator.validateStatus,
            ),

            const SizedBox(height: 24.0),

            // Submit Button
            SizedBox(
              height: 48.0,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Task',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
