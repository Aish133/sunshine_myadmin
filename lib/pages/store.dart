import 'package:flutter/material.dart';
import 'additem_layout.dart';
class StorePage extends StatefulWidget {
  final int initialTabIndex;

  const StorePage({super.key, required this.initialTabIndex});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 7, // GRN, Delivery Challan, Item
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant StorePage oldWidget) {
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
            Tab(text: "Item"),
            Tab(text:"GRN"),
            Tab(text:"Stock"),
            Tab(text: "Delivery Challan"),
            Tab(text:"Shortage"),
            Tab(text: "Purchase Request"),
            Tab(text:"Material Request"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              Center(child: Text("GRN Page")),
              Center(child: Text("Delivery Challan Page")),
              const AddItemLayout(),
            ],
          ),
        ),
      ],
    );
  }
}
