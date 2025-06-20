import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonthlyByEmployee extends StatefulWidget {
  const MonthlyByEmployee({Key? key}) : super(key: key);

  @override
  _MonthlyByEmployeeState createState() => _MonthlyByEmployeeState();
}

class _MonthlyByEmployeeState extends State<MonthlyByEmployee> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic>? _attendanceData;
  List<Map<String, dynamic>> _employees = [];
  String? _selectedEmployeeId;
  bool _isLoading = false;
  Set<DateTime> _presentDays = {};

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('https://www.sunshineagro.in/api/v1/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _employees = data.map((emp) => {
            'emp_id': emp['emp_id'],
            'emp_name': emp['emp_name'],
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employees: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMonthlyAttendance(DateTime date) async {
    if (_selectedEmployeeId == null) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // Get the first and last day of the month
      final firstDay = DateTime(date.year, date.month, 1);
      final lastDay = DateTime(date.year, date.month + 1, 0);

      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/employee/monthly_attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'emp_id': _selectedEmployeeId,
          'start_date': DateFormat('yyyy-MM-dd').format(firstDay),
          'end_date': DateFormat('yyyy-MM-dd').format(lastDay),
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _presentDays = data
              .where((record) => record['in_time'] != null)
              .map((record) => DateTime.parse(record['attendance_date']))
              .toSet();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching monthly attendance: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAttendanceData(DateTime date) async {
    if (_selectedEmployeeId == null) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/employee/attendance_by_date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'emp_id': _selectedEmployeeId,
          'attendance_date': DateFormat('yyyy-MM-dd').format(date),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendanceData = json.decode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attendance: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Attendance'),
        backgroundColor: Colors.blue,
      ),
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
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Employee',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: _selectedEmployeeId,
                    items: _employees.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee['emp_id'].toString(),
                        child: Text('${employee['emp_id']} - ${employee['emp_name']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeId = value;
                        _presentDays.clear();
                      });
                      if (_selectedDay != null) {
                        _fetchAttendanceData(_selectedDay!);
                        _fetchMonthlyAttendance(_focusedDay);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Calendar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      calendarStyle: CalendarStyle(
                        markersMaxCount: 1,
                        markerDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        defaultDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        weekendDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, _) {
                          if (_presentDays.contains(DateTime(date.year, date.month, date.day))) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        selectedBuilder: (context, date, _) {
                          if (_presentDays.contains(DateTime(date.year, date.month, date.day))) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        todayBuilder: (context, date, _) {
                          if (_presentDays.contains(DateTime(date.year, date.month, date.day))) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _fetchAttendanceData(selectedDay);
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        if (_selectedEmployeeId != null) {
                          _fetchMonthlyAttendance(focusedDay);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Attendance Details
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_attendanceData != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attendance Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('In Time', _attendanceData!['in_time'] ?? 'N/A'),
                            _buildDetailRow('Out Time', _attendanceData!['out_time'] ?? 'N/A'),
                            _buildDetailRow('OT Hours', '${_attendanceData!['emp_ot_hrs'] ?? 0} hrs'),
                            _buildDetailRow('OD Hours', '${_attendanceData!['emp_od_hrs'] ?? 0} hrs'),
                            _buildDetailRow('WFH Hours', '${_attendanceData!['emp_wfh_hrs'] ?? 0} hrs'),
                            _buildDetailRow('Holiday Hours', '${_attendanceData!['emp_holiday_hrs'] ?? 0} hrs'),
                            _buildDetailRow('Missed Punch Hours', '${_attendanceData!['emp_missed_punch_hrs'] ?? 0} hrs'),
                            const Divider(height: 24),
                            _buildDetailRow(
                              'Today\'s Total Hours',
                              '${_attendanceData!['emp_basic_hrs'] ?? 0} hrs',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_selectedEmployeeId == null)
                    const Center(
                      child: Text(
                        'Please select an employee',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'No attendance data available',
                        style: TextStyle(fontSize: 16),
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

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}