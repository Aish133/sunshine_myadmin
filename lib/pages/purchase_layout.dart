import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseLayout extends StatefulWidget {
  const PurchaseLayout({Key? key}) : super(key: key);

  @override
  _PurchaseLayoutState createState() => _PurchaseLayoutState();
}

class _PurchaseLayoutState extends State<PurchaseLayout> {
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