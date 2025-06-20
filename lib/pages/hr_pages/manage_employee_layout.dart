import 'package:flutter/material.dart';
import 'add_employee.dart';
import 'edit_employee_details.dart';
import 'employee_details.dart';

class ManageEmployeeLayout extends StatefulWidget {
  const ManageEmployeeLayout({super.key});

  @override
  State<ManageEmployeeLayout> createState() => _ManageEmployeeLayoutState();
}

class _ManageEmployeeLayoutState extends State<ManageEmployeeLayout> {
  // Default page
  Widget _selectedPage = const EmployeeDetails();

  void _onMenuSelected(String value) {
    setState(() {
      switch (value) {
        case 'add':
          _selectedPage = const AddEmployee();
          break;
        case 'edit':
          _selectedPage = const ShowEmployeeDetails();
          break;
        case 'details':
          _selectedPage = const EmployeeDetails();
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
                          value: 'details',
                          child: Text('Employee Details'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Employee Details'),
                        ),
                        const PopupMenuItem(
                          value: 'add',
                          child: Text('Add Employee'),
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