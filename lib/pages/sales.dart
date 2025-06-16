import 'package:flutter/material.dart';
import 'costumer.dart';
class SalesPage extends StatefulWidget {
  final int initialTabIndex;


  const SalesPage({super.key, required this.initialTabIndex});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SalesPage oldWidget) {
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
          controller: tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Customer"),
            Tab(text: "Quotation"),
            Tab(text: "Sales Order"),
            Tab(text: "Sales Invoice"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              const CustomerPage(),
              Center(child: Text("Quotation Page")),
              Center(child: Text("Sales Order Page")),
              Center(child: Text("Sales Invoice Page")),
            ],
          ),
        ),
      ],
    );
  }
}
