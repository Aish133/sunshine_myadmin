import 'package:flutter/material.dart';
import 'custom_arrow.dart';

enum SidebarSection {
  none,
  sales,
  purchase,
  design,
  store,
  production,
  quality,
  account,
  hr,
  admin,
  setup,
}

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onHRArrowTap;
  final VoidCallback onSalesArrowTap;
  final VoidCallback onPurchaseArrowTap;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onHRArrowTap,
    required this.onSalesArrowTap,
    required this.onPurchaseArrowTap,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  SidebarSection expandedSection = SidebarSection.none;

  void toggleExpansion(SidebarSection section) {
    setState(() {
      expandedSection = expandedSection == section ? SidebarSection.none : section;
    });
  }

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
              child: Image.asset('assets/images/sunshine_logo.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildTile("Sales", Icons.point_of_sale, SidebarSection.sales, widget.onSalesArrowTap, [
                  _buildSubItem("Customer", 0),
                  _buildSubItem("Quotation", 1),
                  _buildSubItem("Sales Order", 2),
                  _buildSubItem("Sales Invoice", 3),
                ]),
                buildTile("Purchase", Icons.shopping_cart, SidebarSection.purchase, widget.onPurchaseArrowTap, [
                  _buildSubItem("Suppliers", 4),
                  _buildSubItem("Quote", 5),
                  _buildSubItem("Purchase Order", 6),
                  _buildSubItem("Purchase Invoice", 7),
                ]),
                buildTile("Design", Icons.design_services, SidebarSection.design, widget.onPurchaseArrowTap, [
                  _buildSubItem("Design Dashboard", 8),
                  _buildSubItem("Add BOM", 9),
                  _buildSubItem("Add Test Report", 10),
                ]),
                buildTile("Store", Icons.store, SidebarSection.store, widget.onPurchaseArrowTap, [
                  _buildSubItem("Item", 11),
                  _buildSubItem("GRN", 12),
                  _buildSubItem("Stock", 13),
                  _buildSubItem("Delivery challan", 14),
                  _buildSubItem("Shortages", 15),
                  _buildSubItem("Purchase ReQuest", 16),
                  _buildSubItem("Material Request", 17),
                ]),
                buildTile("Production", Icons.factory, SidebarSection.production, widget.onPurchaseArrowTap, [
                  _buildSubItem("Production Plan", 18),
                ]),
                buildTile("Quality", Icons.verified, SidebarSection.quality, widget.onPurchaseArrowTap, [
                  _buildSubItem("SOP", 19),
                ]),
                buildTile("Account", Icons.account_balance, SidebarSection.account, widget.onPurchaseArrowTap, [
                  _buildSubItem("D", 20),
                  _buildSubItem("Ledger", 21),
                ]),
                buildTile("HR", Icons.people, SidebarSection.hr, widget.onHRArrowTap, [
                  _buildSubItem("Manage Employee", 22),
                  _buildSubItem("Attendance", 23),
                  _buildSubItem("Salary", 24),
                  _buildSubItem("HR Services", 25),
                  _buildSubItem("To Do", 26),
                ]),
                buildTile("Admin", Icons.admin_panel_settings, SidebarSection.admin, widget.onPurchaseArrowTap, [
                  _buildSubItem("System", 27),
                ]),
                buildTile("Setup ERP", Icons.settings, SidebarSection.setup, widget.onPurchaseArrowTap, [
                  _buildSubItem("Create Master", 28),
                ]),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () => print("Logout tapped"),
          ),
        ],
      ),
    );
  }

  Widget buildTile(String title, IconData icon, SidebarSection section, VoidCallback onTitleTap, List<Widget> children) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: CustomExpansionTileWithArrowTap(
        title: title,
        icon: icon,
        isExpanded: expandedSection == section,
        onTitleTap: onTitleTap, // ✅ only title navigates
        onArrowTap: () => toggleExpansion(section), // ✅ only arrow expands
        children: children,
      ),
    );
  }

  Widget _buildSubItem(String label, int index) {
    return ListTile(
      
      
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      onTap: () => widget.onItemSelected(index),
    );
  }
}
