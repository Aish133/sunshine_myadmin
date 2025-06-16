// import 'package:flutter/material.dart';
// import 'sidebar.dart';
// import 'top_navbar.dart';

// // Import your pages
// import 'pages/customer_page.dart';
// import 'pages/quotation_page.dart';
// import 'pages/dashboard_page.dart';
// import 'pages/employees_page.dart';
// import 'pages/attendance_page.dart';
// import 'pages/leave_page.dart';
// import 'pages/salary_page.dart';
// import 'pages/hr_policy_page.dart';
// import 'pages/ledger_page.dart';


// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int selectedIndex = 0;
//   double sidebarWidth = 240;

//   // List of all sidebar subitems (add all as needed)
//   final List<Widget> pages = [
//   const DashboardPage(),
//   const EmployeesPage(),
//   const AttendancePage(),
//   const LeavePage(),
//   const SalaryPage(),
//   const HrPolicyPage(),
//   const LedgerPage(),
// ];

//  \

//   void handleSidebarTap(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: Row(
//         children: [
//           GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onHorizontalDragUpdate: (details) {
//               setState(() {
//                 sidebarWidth += details.delta.dx;
//                 sidebarWidth = sidebarWidth.clamp(180, 400);
//               });
//             },
//             child: SizedBox(
//               width: sidebarWidth,
//               child: Sidebar(
//                 selectedIndex: selectedIndex,
//                 onItemSelected: handleSidebarTap,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 TopNavbar(
//                   selectedIndex: selectedIndex,
//                   subItems: subItems,
//                   onTileTap: handleSidebarTap,
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).cardColor,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             spreadRadius: 2,
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(24),
//                       child: pages[selectedIndex],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//   /// Returns the widget corresponding to the selected index
//   Widget _getSelectedPage(int index) {
//     switch (index) {
//       case 0:
//         return const CustomerPage();
//       case 1:
//         return const QuotationPage();
//       // Add other cases as needed...
//       default:
//         return const Center(child: Text('Select a menu item'));
//     }
//   }


import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_navbar.dart';

// Import your modular pages
import 'pages/dashboard_page.dart';
import 'pages/customer_page.dart';
import 'pages/supplier_page.dart';  
import 'pages/additem_page.dart'
import 'pages/employees_page.dart';
import 'pages/attendance_page.dart';
import 'pages/leave_page.dart';
import 'pages/salary_page.dart';
import 'pages/hr_policy_page.dart';
import 'pages/ledger_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  // List of all pages mapped to selectedIndex
  final List<Widget> pages = const [
    DashboardPage(),
    CustomerPage(),
    SupplierPage(),
    AddItemPage(),
    EmployeesPage(),
    AttendancePage(),
    LeavePage(),
    SalaryPage(),
    HrPolicyPage(),
    LedgerPage(),
  ];

  // Handler when a sidebar item is tapped
  void handleSidebarTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Handler for TopNavbar (in case sub-items are used)
  void handleSubItemTap(int subIndex) {
    setState(() {
      selectedIndex = subIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemTap: handleSidebarTap,
          ),
          Expanded(
            child: Column(
              children: [
                TopNavbar(
                  selectedIndex: selectedIndex,
                  onSubItemTap: handleSubItemTap,
                ),
                Expanded(
                  child: pages[selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
