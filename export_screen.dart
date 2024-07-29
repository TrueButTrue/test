import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'assignment_data.dart';

class ExportScreen extends StatelessWidget {
  final List<AssignmentData> assignments;

  const ExportScreen({super.key, required this.assignments});

  Future<void> exportToExcel(List<AssignmentData> assignments, BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Define header row
    var header = ['Volunteer', 'Activity', 'Category', 'Email', 'Company'];
    for (int i = 0; i < header.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = header[i] as CellValue?;
    }

    // Append data rows
    for (int i = 0; i < assignments.length; i++) {
      var assignment = assignments[i];
      var rowIndex = i + 1; // Start from the second row
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = assignment.volunteer as CellValue?;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = assignment.activity as CellValue?;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = assignment.category as CellValue?;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = assignment.email as CellValue?;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = assignment.company as CellValue?;
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Assignments.xlsx';
    final file = File(filePath);
    var fileBytes = excel.save();
    if (fileBytes != null) {
      file.writeAsBytesSync(fileBytes);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel file saved at: $filePath')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save the Excel file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assignment Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return ListTile(
                    title: Text('${assignment.volunteer} - ${assignment.activity}'),
                    subtitle: Text('Category: ${assignment.category}, Email: ${assignment.email}, Company: ${assignment.company}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => exportToExcel(assignments, context),
                child: const Text('Export to Excel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}