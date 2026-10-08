import 'package:flutter/material.dart';
import '../../utils/create_validator.dart';
import '../services/database_helper.dart';

class createTaskForm extends StatefulWidget {
  @override
  State<createTaskForm> createState() => _createTaskFormState();
}

class _createTaskFormState extends State<createTaskForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            // Task title
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              validator: CreateValidator.validateTitle,
            ),

            SizedBox(height: 16.0),

            // Task description
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              validator: CreateValidator.validateDescription,
            ),

            SizedBox(height: 16.0),

            // Assigned To
            Text(
              "Assigned To",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.0),

            // Call the user list from the database
            FutureBuilder<List<User>>(
              future: DatabaseHelper.instance.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Text('No users found');
                } else {
                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Select User',
                    ),
                    items: snapshot.data!.map((user) {
                      return DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Handle user selection
                    },
                  );
                }
              },
            ),

            SizedBox(height: 16.0),

            // Due date
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Deadline',
              ),
              readOnly: true,
              onTap: () async {
                FocusScope.of(context).unfocus();

                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  print(pickedDate);
                }
              },
            ),

            SizedBox(height: 16.0),

            // Priority
            Text(
              "Priority",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.0),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Priority',
              ),
              items: ['Low', 'Medium', 'High'].map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                // Handle priority selection
              },
            ),

            SizedBox(height: 16.0),

            // Status
            Text(
              "Status",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.0),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Status',
              ),
              items: ['To-do', 'In Progress', 'Completed'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                // Handle status selection
              },
            ),

            SizedBox(height: 20.0),

            // Submit
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process data
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}