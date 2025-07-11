import 'package:flutter/material.dart';
import 'supplier_layout.dart';
class PurchasePage extends StatefulWidget {
  final int initialTabIndex;

  const PurchasePage({super.key, required this.initialTabIndex});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage>
    with TickerProviderStateMixin {
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
  void didUpdateWidget(covariant PurchasePage oldWidget) {
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
            Tab(text: "Suppliers"),
            Tab(text: "Quote"),
            Tab(text: "Purchase Order"),
            Tab(text: "Purchase Invoice"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              const SupplierLayout(),
              Center(child: Text("Quote Page")),
              Center(child: Text("Purchase Order Page")),
              Center(child: Text("Purchase Invoice Page")),
            ],
          ),
        ),
      ],
    );
  }
}
