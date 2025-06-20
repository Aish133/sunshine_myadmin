import 'package:flutter/material.dart';
import 'attendance_layout.dart';
import 'manage_employee_layout.dart';
import 'holiday.dart';
import 'salary_layout.dart';
class HR extends StatefulWidget {
  final int initialTabIndex;


  const HR({super.key, required this.initialTabIndex});

  @override
  State<HR> createState() => _HRState();
}

class _HRState extends State<HR> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant HR oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      tabController.animateTo(widget.initialTabIndex);
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          indicatorColor: Colors.black,
          controller: tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Manage Employee"),
            Tab(text: "Attendance"),
            Tab(text: "Salary"),
            Tab(text: "HR Services"),
            Tab(text: "To Do"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              ManageEmployeeLayout(),
              AttendanceLayout(),
              SalaryLayout(),
              HolidayScreen(),
              Center(child: Text("HR Services"))
            ],
          ),
        ),
      ],
    );
  }
}
