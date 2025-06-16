import 'package:flutter/material.dart';
import 'constants/navigation_items.dart'; // Import the shared navigation item list

class TopNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSubItemTap;

  const TopNavbar({
    super.key,
    required this.selectedIndex,
    required this.onSubItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: const Color(0xFF2A2A2A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            navigationItems[selectedIndex].label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Add notification logic if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add settings logic if needed
            },
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
