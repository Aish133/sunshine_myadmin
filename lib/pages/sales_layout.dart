import 'package:flutter/material.dart';

class SalesLayout extends StatefulWidget {
  const SalesLayout({Key? key}) : super(key: key);

  @override
  _SalesLayoutState createState() => _SalesLayoutState();
}

class _SalesLayoutState extends State<SalesLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFFF5F5F5),
      body: const Center(

        child: Text(
          "Hello Geeks!!" ),
      ),
    );
  }
}