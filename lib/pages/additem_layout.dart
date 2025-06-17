import 'package:flutter/material.dart';
import 'additem_page.dart';

class AddItemLayout extends StatefulWidget {
  const AddItemLayout({super.key});

  @override
  State<AddItemLayout> createState() => _AddItemLayoutState();
}

class _AddItemLayoutState extends State<AddItemLayout> {
  bool showAddItemForm = false;

  @override
  Widget build(BuildContext context) {
    if (showAddItemForm) {
      return const AddItemPage(); // Directly show the Add Item form
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showAddItemForm = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        textStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Add Item'),
                    ),
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