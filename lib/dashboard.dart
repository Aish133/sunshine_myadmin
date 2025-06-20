import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_navbar.dart';
import 'pages/sales.dart';
import 'pages/purchase.dart';
import 'pages/store.dart';
import 'pages/hr_pages/hr.dart';
import 'pages/birthday.dart';
import 'pages/sales_layout.dart';
import 'pages/purchase_layout.dart';

/// ✅ Declare the missing class DashboardScreen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = -1;
  Widget? activeCustomPage; // 🆕 Used for custom layouts like CustomerLayout

  void handleSidebarTap(int index) {
    setState(() {
      selectedIndex = index;
      activeCustomPage = null; // clear custom page when tab selected
    });
  }

  void handleCustomPage(Widget page) {
    setState(() {
      activeCustomPage = page;
      selectedIndex = -1; // clear selected index when loading custom page
    });
  }

  String getCurrentTitle() {
    if (activeCustomPage is BirthdayPage) return "HR Panel";
    if (activeCustomPage is SalesLayout)  return "Sales";
    if (activeCustomPage is PurchaseLayout) return "Purchase";
    if (selectedIndex >= 0 && selectedIndex <= 3) return "Sales";
    if (selectedIndex >= 4 && selectedIndex <= 7) return "Purchase";
    if (selectedIndex >= 8 && selectedIndex <= 10) return "Design";
    if (selectedIndex >= 11 && selectedIndex <= 17) return "Store";
    if (selectedIndex == 18) return "Production & Planning";
    if (selectedIndex == 19) return "Quality";
    if (selectedIndex >= 20 && selectedIndex <= 21) return "Account";
    if (selectedIndex >= 22 && selectedIndex <= 26) return "HR";
    if (selectedIndex == 27) return "Admin";
    if (selectedIndex == 28) return "Store";

    return "Dashboard";
  }

  String getCurrentSection() {
    if (selectedIndex >= 0 && selectedIndex <= 21) {
      return "sales";
    }
    return "dashboard";
  }

  Widget getCurrentPage() {
    if (activeCustomPage != null) return activeCustomPage!;

    if (selectedIndex >= 0 && selectedIndex <= 3) {
      return SalesPage(initialTabIndex: selectedIndex);
    }
    if (selectedIndex >= 4 && selectedIndex <= 7) {
      return PurchasePage(initialTabIndex: selectedIndex - 4);
    }
    if (selectedIndex >= 11 && selectedIndex <= 17) {
      return StorePage(initialTabIndex: selectedIndex - 11);
    }
    if (selectedIndex >= 22 && selectedIndex <= 26) {
      return HR(initialTabIndex: selectedIndex - 22);
    }

    return const Center(
      child: Text("Main Dashboard Content", style: TextStyle(fontSize: 24)),
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
            onHRArrowTap: () => handleCustomPage(const BirthdayPage()), // 🆕 handles HR arrow click
            onSalesArrowTap:()=> handleCustomPage(const SalesLayout()),
            onPurchaseArrowTap:()=>handleCustomPage(const PurchaseLayout()),
          ),
          Expanded(
            child: Column(
              children: [
                TopNavbar(
                  title: getCurrentTitle(),
                  section: getCurrentSection(),
                ),
                Expanded(
                  child: getCurrentPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
