import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          /// Scrollable menu content
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 30,
                    child: Image.asset(
                      'assets/images/sunshine_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                /// 🔽 SALES
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.point_of_sale, color: Colors.white),
                    title: const Text('Sales', style: TextStyle(color: Colors.white)),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    childrenPadding: const EdgeInsets.only(left: 20),
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
                  child: ExpansionTile(
                    leading: const Icon(Icons.shopping_cart, color: Colors.white),
                    title: const Text('Purchase', style: TextStyle(color: Colors.white)),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    childrenPadding: const EdgeInsets.only(left: 20),
                    children: [
                      _buildSubItem("Suppliers", 4),
                      _buildSubItem("Quote", 5),
                      _buildSubItem("Purchase Order", 6),
                      _buildSubItem("Purchase Invoice", 7),
                    ],
                  ),
                ),

                /// 🔽 STORE
                Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.store, color: Colors.white),
                    title: const Text('Store', style: TextStyle(color: Colors.white)),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    childrenPadding: const EdgeInsets.only(left: 20),
                    children: [
                      _buildSubItem("GRN", 8),
                      _buildSubItem("Delivery Challan", 9),
                      _buildSubItem("Item", 10),
                    ],
                  ),
                ),

                /// Other Main Items
                ListTile(
                  leading: const Icon(Icons.factory, color: Colors.white),
                  title: const Text('Production', style: TextStyle(color: Colors.white)),
                  onTap: () => onItemSelected(11),
                ),
                ListTile(
                  leading: const Icon(Icons.verified, color: Colors.white),
                  title: const Text('Quality', style: TextStyle(color: Colors.white)),
                  onTap: () => onItemSelected(12),
                ),
                ListTile(
                  leading: const Icon(Icons.design_services, color: Colors.white),
                  title: const Text('Design', style: TextStyle(color: Colors.white)),
                  onTap: () => onItemSelected(13),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.white),
                  title: const Text('HR', style: TextStyle(color: Colors.white)),
                  onTap: () => onItemSelected(14),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  title: const Text('Admin', style: TextStyle(color: Colors.white)),
                  onTap: () => onItemSelected(15),
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
