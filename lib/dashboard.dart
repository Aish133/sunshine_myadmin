import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_navbar.dart';
import 'pages/sales.dart';
import 'pages/purchase.dart';
import 'pages/store.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = -1;

  void handleSidebarTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  String getCurrentSection() {
  if (selectedIndex >= 0 && selectedIndex <= 10) {
    return "sales";
  }
  return "dashboard";
}

String getCurrentTitle() {
  if (selectedIndex >= 0 && selectedIndex <= 3) {
    return "Sales";
  }
  if (selectedIndex >= 4 && selectedIndex <= 7) {
    return "Purchase";
  }
   if (selectedIndex >= 8 && selectedIndex <= 10) {
    return "Store";
  }
  return "Dashboard";
}

  Widget getCurrentPage() {
    if (selectedIndex >= 0 && selectedIndex <= 3) {
      return SalesPage(initialTabIndex: selectedIndex);
    }
     if (selectedIndex >= 4 && selectedIndex <= 7) {
    return PurchasePage(initialTabIndex: selectedIndex - 4); // Normalize index to 0–3
  }
     if (selectedIndex >= 8 && selectedIndex <= 10) {
    return StorePage(initialTabIndex: selectedIndex - 8);
  }



    // Add more conditions for other indexes like PurchasePage, etc.
    return const Center(
      child: Text(
        "Main Dashboard Content",
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: handleSidebarTap,
          ),
          Expanded(
            child: Column(
              children: [
                TopNavbar(
                          title: getCurrentTitle(),
                          section: getCurrentSection(),
                            ),
                Expanded(
                  child: getCurrentPage(), // ✅ Use dynamic page here
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
