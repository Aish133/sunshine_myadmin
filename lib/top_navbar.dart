import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget {
  final String title;
  final String section; // e.g., "dashboard", "sales", "purchase"

  const TopNavbar({super.key, required this.title, required this.section});

  @override
  Widget build(BuildContext context) {
    final bool isSales = section == "sales";

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
     color: isSales ? Color(0xFFF5F5F5) : Colors.black, 
      child: Row(
        children: [
          Icon(
            Icons.business,
            color: isSales ? Colors.black : Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isSales ? Colors.black : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Icon(Icons.search, color: isSales ? Colors.black54 : Colors.white),
          const SizedBox(width: 20),
          Icon(Icons.notifications_none,
              color: isSales ? Colors.black54 : Colors.white),
          const SizedBox(width: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aishwarya Meshram",
                    style: TextStyle(
                      color: isSales ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Aishw32@gmail.com",
                    style: TextStyle(
                      color: isSales ? Colors.black54 : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down,
                  color: isSales ? Colors.black : Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
