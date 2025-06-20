import 'package:flutter/material.dart';

class CustomExpansionTileWithArrowTap extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback onArrowTap;

  const CustomExpansionTileWithArrowTap({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.onArrowTap,
  });

  @override
  State<CustomExpansionTileWithArrowTap> createState() => _CustomExpansionTileWithArrowTapState();
}

class _CustomExpansionTileWithArrowTapState extends State<CustomExpansionTileWithArrowTap> {
  bool _expanded = false;

  void _handleArrowTap() {
    setState(() {
      _expanded = !_expanded;
    });

    // Navigate to page
    widget.onArrowTap();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(widget.icon, color: Colors.white),
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: GestureDetector(
            onTap: _handleArrowTap,
            child: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(children: widget.children),
          ),
      ],
    );
  }
}
