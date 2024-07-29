import 'package:flutter/material.dart';
import 'assignment_data.dart';
import 'export_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: assignmentList.length,
              itemBuilder: (context, index) {
                final assignment = assignmentList[index];
                return ListTile(
                  title: Text('${assignment.volunteer} - ${assignment.activity}'),
                  subtitle: Text('Category: ${assignment.category}, Email: ${assignment.email}, Company: ${assignment.company}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExportScreen(assignments: assignmentList),
                  ),
                );
              },
              child: const Text('Export to Files'),
            ),
          ),
        ],
      ),
    );
  }
}
