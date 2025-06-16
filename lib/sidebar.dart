import 'package:flutter/material.dart';
import 'constants/navigation_items.dart'; // Import the navigationItems list

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTap;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1F1F1F),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
  padding: const EdgeInsets.all(16.0),
  child: Image.asset(
    'assets/sunshine_logo.png',
    height: 80, // Adjust height as needed
    fit: BoxFit.contain,
  ),
),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: navigationItems.length,
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final isSelected = selectedIndex == index;

                return ListTile(
                  leading: Icon(item.icon,
                      color: isSelected ? Colors.blue : Colors.white),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () => onItemTap(index),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}