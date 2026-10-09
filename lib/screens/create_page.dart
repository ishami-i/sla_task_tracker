import 'package:flutter/material.dart';
import '../widgets/createTask_form.dart';

// the page for creating the task
class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
        centerTitle: true,
      ),
      body: createTaskForm(),
    );
  }
}
