import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  void handleSidebarTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5), // light blue background
    body: Row(
      children: [
        Sidebar(
          selectedIndex: selectedIndex,
          onItemSelected: handleSidebarTap,
        ),
        Expanded(
          child: Column(
            children: const [
              TopNavbar(),
              Expanded(
                child: Center(
                  child: Text(
                    "Main Dashboard Content",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}