import 'package:flutter/material.dart';
import 'daily_records.dart';
import 'monthly_by_employee.dart';
import 'monthly_reports.dart';
import 'attendence_request.dart';

class AttendanceLayout extends StatefulWidget {
  const AttendanceLayout({super.key});

  @override
  State<AttendanceLayout> createState() => _AttendanceLayoutState();
}

class _AttendanceLayoutState extends State<AttendanceLayout> {
  Widget _selectedPage = const DailyRecord();

  void _onMenuSelected(String value) {
    setState(() {
      switch (value) {
        case 'daily':
          _selectedPage = const DailyRecord();
          break;
        case 'monthly_employee':
          _selectedPage = const MonthlyByEmployee();
          break;
        case 'monthly_report':
          _selectedPage = const MonthlyReports();
          break;
        case 'request':
          _selectedPage = const AttendanceRequest();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Top menu bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: _onMenuSelected,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'daily',
                          child: Text('Daily Record'),
                        ),
                        const PopupMenuItem(
                          value: 'monthly_employee',
                          child: Text('Monthly by Employee'),
                        ),
                        const PopupMenuItem(
                          value: 'monthly_report',
                          child: Text('Monthly Reports'),
                        ),
                        const PopupMenuItem(
                          value: 'request',
                          child: Text('Attendance Request'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),

                // Responsive content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedPage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}