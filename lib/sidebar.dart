import 'package:flutter/material.dart';
import 'custom_arrow.dart';
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final void Function() onHRArrowTap;
  final void Function() onSalesArrowTap;
  final void Function() onPurchaseArrowTap;
  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onHRArrowTap,
    required this.onSalesArrowTap,
    required this.onPurchaseArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 70,
                    child: Image.asset(
                      'assets/images/sunshine_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                 Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [ 
                 /// 🔽 SALES
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Sales",
                    icon: Icons.point_of_sale,
                    onArrowTap: onSalesArrowTap,
                    children: [
                      _buildSubItem("Customer", 0),
                      _buildSubItem("Quotation", 1),
                      _buildSubItem("Sales Order", 2),
                      _buildSubItem("Sales Invoice", 3),
                    ],
                  ),
                ),
                /// 🔽 PURCHASE
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Purchase",
                    icon: Icons.shopping_cart,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("Suppliers", 4),
                      _buildSubItem("Quote", 5),
                      _buildSubItem("Purchase Order", 6),
                      _buildSubItem("Purchase Invoice", 7),
                    ],
                  ),
                ),
                /// Design
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Design",
                    icon: Icons.design_services,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("Design Dashboard", 8),
                      _buildSubItem("Add BOM", 9),
                      _buildSubItem("Add Test Report", 10),
                    ],
                  ),
                ),
                ///store
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Store",
                    icon: Icons.store,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("Item", 11),
                      _buildSubItem("GRN", 12),
                      _buildSubItem("Stock", 13),
                      _buildSubItem("Delivery challan", 14),
                      _buildSubItem("Shortages", 15),
                      _buildSubItem("Purchase ReQuest", 16),
                      _buildSubItem("Material Request", 17),
                    ],
                  ),
                ),
                /// production planning
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Production",
                    icon: Icons.factory,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("Production Plan", 18),
                    
                    ],
                  ),
                ),
                ///Quality
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Quality",
                    icon: Icons.verified,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("SOP", 19),
                    ],
                  ),
                ),
                ///Account
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Account",
                    icon: Icons.design_services,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("D", 20),
                      _buildSubItem("Ledger", 21),

                    ],
                  ),
                ),
///HR
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "HR",
                    icon: Icons.people,
                    onArrowTap: onHRArrowTap,
                    children: [
                      _buildSubItem("Mange Employee", 22),
                      _buildSubItem("Attendance", 23),
                      _buildSubItem("Salary", 24),
                      _buildSubItem("HR Services", 25),
                      _buildSubItem("To Do", 26),
                    ],
                  ),
                ),

                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Admin",
                    icon: Icons.admin_panel_settings,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("System", 27),
                    ],
                  ),
                ),
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: CustomExpansionTileWithArrowTap(
                    title: "Setup ERP",
                    icon: Icons.shopping_cart,
                    onArrowTap:onPurchaseArrowTap,
                    children: [
                      _buildSubItem("Create Master", 28),
                    ],
                  ),
                ),
                
              ],
            ),
          ),

          /// 🔽 Logout button at the bottom
          const Divider(color: Colors.white24),
          ListTile(
            
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              // Add logout functionality here
              print("Logout tapped");
              // Example: Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem(String label, int index) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      onTap: () => onItemSelected(index),
    );
  }
}