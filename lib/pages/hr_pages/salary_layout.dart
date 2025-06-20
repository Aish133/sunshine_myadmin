import 'package:flutter/material.dart';
import 'salary_ledger.dart';
import 'advance_ledger.dart';

class SalaryLayout extends StatefulWidget {
  const SalaryLayout({super.key});

  @override
  State<SalaryLayout> createState() => _SalaryLayoutState();
}

class _SalaryLayoutState extends State<SalaryLayout> {
  Widget _selectedPage = const SalaryLedger();

  void _onMenuSelected(String value) {
    setState(() {
      switch (value) {
        case 'salary':
          _selectedPage = const SalaryLedger();
          break;
        case 'advance':
          _selectedPage = const AdvanceLedger();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Top-right 3-dot menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: _onMenuSelected,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'salary',
                          child: Text('Salary Ledger'),
                        ),
                        const PopupMenuItem(
                          value: 'advance',
                          child: Text('Advance Ledger'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),

                // Main content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedPage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}