import 'package:flutter/material.dart';

class CustomExpansionTileWithArrowTap extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback onTitleTap;
  final VoidCallback onArrowTap;
  final bool isExpanded;

  const CustomExpansionTileWithArrowTap({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.onTitleTap,
    required this.onArrowTap,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: GestureDetector(
            onTap: onTitleTap,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: GestureDetector(
            onTap: onArrowTap,
            child: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(children: children),
          ),
      ],
    );
  }
}
