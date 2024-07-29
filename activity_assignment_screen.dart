import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'done_screen.dart';
import 'admin_screen.dart';
import 'assignment_data.dart';

class ActivityAssignmentScreen extends StatefulWidget {
  const ActivityAssignmentScreen({super.key});

  @override
  _ActivityAssignmentScreenState createState() => _ActivityAssignmentScreenState();
}

class _ActivityAssignmentScreenState extends State<ActivityAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? selectedVolunteer;
  String? selectedActivity;
  String? selectedCategory;
  List<String> volunteers = [
    'Muneeza Qureshi', 'Siraj Mohammad', 'Faraaz Husain', 'Aaahil Penwalla',
    'Mohamed Junaid Ghani', 'Sidra Dakhel', 'Ryan Vaseem',
    'Abbas Haq', 'Isra Osmani', 'Khashiya Ranginwala',
    'Anisa Ismail'
  ];
  List<String> categories = [
    'Business Analysis', 'Design', 'Programming', 'Data Analysis', 'Testing SQA'
  ];
  List<String> activities = [];

  void fetchActivities(String category) {
    setState(() {
      activities = getActivitiesByCategory(category);
      selectedActivity = null;
    });
  }

  List<String> getActivitiesByCategory(String category) {
    switch (category) {
      case 'Business Analysis':
        return ['Activity 1', 'Activity 2'];
      case 'Design':
        return ['Activity 3', 'Activity 4'];
      case 'Programming':
        return ['Activity 5', 'Activity 6'];
      case 'Data Analysis':
        return ['Create UI Activity Assignment'];
      case 'Testing SQA':
        return ['Activity 7', 'Activity 8'];
      default:
        return [];
    }
  }

  void assignActivity() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isDuplicateAssignment()) {
        showErrorSnackbar('Duplicate assignment not allowed');
        return;
      }
      final assignment = AssignmentData(
        volunteer: selectedVolunteer!,
        activity: selectedActivity!,
        category: selectedCategory!,
        email: _emailController.text,
        company: _companyController.text,
      );
      assignmentList.add(assignment);

      await sendEmail(_emailController.text, selectedActivity!, selectedVolunteer!, selectedCategory!, _companyController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoneScreen()),
      );
    } else {
      showErrorSnackbar('Please fill out all fields');
    }
  }

  bool _isDuplicateAssignment() {
    return assignmentList.any((assignment) =>
    assignment.volunteer == selectedVolunteer && assignment.activity == selectedActivity);
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void addNewVolunteer(String name) {
    if (name.isNotEmpty) {
      if (volunteers.contains(name)) {
        showErrorSnackbar('Volunteer already exists');
      } else {
        setState(() {
          volunteers.add(name);
        });
      }
    }
  }

  void addNewActivity(String name) {
    if (name.isNotEmpty && selectedCategory != null) {
      if (activities.contains(name)) {
        showErrorSnackbar('Activity already exists');
      } else {
        setState(() {
          activities.add(name);
        });
      }
    }
  }

  void addNewCategory(String name) {
    if (name.isNotEmpty) {
      if (categories.contains(name)) {
        showErrorSnackbar('Category already exists');
      } else {
        setState(() {
          categories.add(name);
        });
      }
    }
  }

  Future<void> showAddDialog({required String type, required Function(String) onAdd}) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New $type'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $type name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onAdd(controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendEmail(String email, String activity, String volunteer, String category, String company) async {
    try {
      final String apiKey = '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';
      final url = Uri.parse('https://api.brevo.com/v3/smtp/email');
      final response = await http.post(
        url,
        headers: <String, String>{
          'api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'sender': {'email': 'ryanvaseem33@gmail.com', 'name': company},
          'to': [
            {'email': email}
          ],
          'subject': 'Activity Assignment',
          'htmlContent': '<html><body>Dear $volunteer, you have been assigned to the following activity: $activity under the category $category.</body></html>',
        }),
      );

      if (response.statusCode == 201) {
        print('Email sent successfully');
      } else {
        print('Failed to send email: ${response.statusCode}');
        print('Response body: ${response.body}');
        showErrorSnackbar('Could not send email: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
      showErrorSnackbar('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Activity',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Volunteer'),
                value: selectedVolunteer,
                items: volunteers.map((volunteer) {
                  return DropdownMenuItem<String>(
                    value: volunteer,
                    child: Text(volunteer),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVolunteer = value;
                    selectedActivity = null;
                  });
                },
                validator: (value) => value == null ? 'Please select a volunteer' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => showAddDialog(type: 'Volunteer', onAdd: addNewVolunteer),
                child: const Text('Add Volunteer'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Category'),
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    fetchActivities(value!);
                    selectedActivity = null;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => showAddDialog(type: 'Category', onAdd: addNewCategory),
                child: const Text('Add Category'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Activity'),
                value: selectedActivity,
                items: activities.map((activity) {
                  return DropdownMenuItem<String>(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivity = value;
                  });
                },
                validator: (value) => value == null ? 'Please select an activity' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => showAddDialog(type: 'Activity', onAdd: addNewActivity),
                child: const Text('Add Activity'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Volunteer Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: assignActivity,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
