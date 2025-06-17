import 'package:flutter/material.dart';

class HR extends StatefulWidget {
  final int initialTabIndex;


  const HR({super.key, required this.initialTabIndex});

  @override
  State<HR> createState() => _HRState();
}

class _HRState extends State<HR> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant HR oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      tabController.animateTo(widget.initialTabIndex);
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          indicatorColor: Colors.black,
          controller: tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Attendance"),
            Tab(text: "Salary"),
            Tab(text: "Manage Employee"),
            Tab(text: "Ledgers"),
            Tab(text: "HR Services"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              Center(child: Text("Quotation Page")),
              Center(child: Text("Quotation Page")),
              Center(child: Text("Sales Order Page")),
              Center(child: Text("Sales Invoice Page")),
              Center(child: Text("HR Services"))
            ],
          ),
        ),
      ],
    );
  }
}
