import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MonthlyReports extends StatefulWidget {
  const MonthlyReports({Key? key}) : super(key: key);

  @override
  State<MonthlyReports> createState() => _MonthlyReportsState();
}

class _MonthlyReportsState extends State<MonthlyReports> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> employees = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchMonthlyReport() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a month and year')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final year = selectedDate!.year;
      final month = selectedDate!.month.toString().padLeft(2, '0');

      final response = await http.put(
        Uri.parse('https://www.sunshineagro.in/api/v1/attendance/process_monthly'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'attendance_month': '$year-$month',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['body'] != null) {
          // Convert the response data to the correct format
          final List<dynamic> responseData = data['body'];
          setState(() {
            employees = responseData.map((employee) {
              // Create a new map to store the transformed data
              Map<String, dynamic> transformedEmployee = Map<String, dynamic>.from(employee);
              
              // Convert attendance records to proper format
              if (transformedEmployee['attendance_records'] != null) {
                List<dynamic> records = transformedEmployee['attendance_records'] as List;
                transformedEmployee['attendance_records'] = records.map((record) {
                  // Create a new map for each record
                  Map<String, dynamic> transformedRecord = Map<String, dynamic>.from(record);
                  
                  // Convert numeric strings to doubles
                  transformedRecord['emp_basic_hrs'] = double.tryParse(transformedRecord['emp_basic_hrs']?.toString() ?? '0') ?? 0.0;
                  transformedRecord['emp_extra_hrs'] = double.tryParse(transformedRecord['emp_extra_hrs']?.toString() ?? '0') ?? 0.0;
                  transformedRecord['emp_missed_punch_hrs'] = double.tryParse(transformedRecord['emp_missed_punch_hrs']?.toString() ?? '0') ?? 0.0;
                  transformedRecord['emp_od_hrs'] = double.tryParse(transformedRecord['emp_od_hrs']?.toString() ?? '0') ?? 0.0;
                  transformedRecord['emp_ot_hrs'] = double.tryParse(transformedRecord['emp_ot_hrs']?.toString() ?? '0') ?? 0.0;
                  transformedRecord['emp_wfh_hrs'] = double.tryParse(transformedRecord['emp_wfh_hrs']?.toString() ?? '0') ?? 0.0;
                  transformedRecord['emp_total_working_hrs'] = double.tryParse(transformedRecord['emp_total_working_hrs']?.toString() ?? '0') ?? 0.0;
                  
                  return transformedRecord;
                }).toList();
              }
              return transformedEmployee;
            }).toList();
          });
        } else {
          throw Exception('No data received from server');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> exportToExcel() async {
    if (employees.isEmpty) return;

    final excel = Excel.createExcel();
    final sheet = excel.sheets.values.first;

    // Add headers
    final headers = ['Employee Name', 'Employee ID', 'Date', 'Basic Hours', 
                    'Extra Working Hours', 'Missed Punch Hours', 'OD Hours', 
                    'OT Hours', 'WFH Hours', 'Total Working Hours'];
    
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = headers[i];
    }

    // Add data
    int rowIndex = 1;
    for (var employee in employees) {
      for (var record in employee['attendance_records']) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = employee['emp_name'];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = employee['emp_id'];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = record['attendance_date'];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = record['emp_basic_hrs']?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = record['emp_extra_hrs']?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = record['emp_missed_punch_hrs']?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = record['emp_od_hrs']?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = record['emp_ot_hrs']?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = record['emp_wfh_hrs']?.toString() ?? '0';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = record['emp_total_working_hrs']?.toString() ?? '0';
        rowIndex++;
      }
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}_Attendance.xlsx';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File saved to: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDatePickerMode: DatePickerMode.year,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = DateTime(picked.year, picked.month);
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null
                                ? 'Select Month and Year'
                                : DateFormat('MMMM yyyy').format(selectedDate!),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: fetchMonthlyReport,
                        child: const Text('Apply'),
                      ),
                      if (employees.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: exportToExcel,
                            child: const Text('Download Excel'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (employees.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Employee Name')),
                          DataColumn(label: Text('Employee ID')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Basic Hours')),
                          DataColumn(label: Text('Extra Hours')),
                          DataColumn(label: Text('Missed Punch')),
                          DataColumn(label: Text('OD Hours')),
                          DataColumn(label: Text('OT Hours')),
                          DataColumn(label: Text('WFH Hours')),
                          DataColumn(label: Text('Total Hours')),
                        ],
                        rows: employees.map((employee) {
                          // Ensure attendance_records exists and is a List
                          final records = (employee['attendance_records'] as List?) ?? [];
                          
                          return records.map<DataRow>((record) {
                            // Ensure record is a Map
                            if (record is! Map<String, dynamic>) {
                              return DataRow(
                                cells: List.generate(10, (index) => 
                                  DataCell(Text('Invalid Data'))
                                ),
                              );
                            }

                            return DataRow(
                              cells: [
                                DataCell(Text(employee['emp_name']?.toString() ?? 'N/A')),
                                DataCell(Text(employee['emp_id']?.toString() ?? 'N/A')),
                                DataCell(Text(record['attendance_date']?.toString() ?? 'N/A')),
                                DataCell(Text(record['emp_basic_hrs']?.toString() ?? '0')),
                                DataCell(Text(record['emp_extra_hrs']?.toString() ?? '0')),
                                DataCell(Text(record['emp_missed_punch_hrs']?.toString() ?? '0')),
                                DataCell(Text(record['emp_od_hrs']?.toString() ?? '0')),
                                DataCell(Text(record['emp_ot_hrs']?.toString() ?? '0')),
                                DataCell(Text(record['emp_wfh_hrs']?.toString() ?? '0')),
                                DataCell(Text(record['emp_total_working_hrs']?.toString() ?? '0')),
                              ],
                            );
                          }).toList();
                        }).expand((rows) => rows).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}