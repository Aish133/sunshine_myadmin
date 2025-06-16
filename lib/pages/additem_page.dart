import 'package:flutter/material.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController itemCode = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController unitOfMeasure = TextEditingController();
  final TextEditingController category = TextEditingController();
  final TextEditingController standardPackingQty = TextEditingController();
  final TextEditingController minimumOrderQty = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController hsn = TextEditingController();

  bool supplierTestReport = false;
  bool iqcBatch = false;
  double iqcPercentage = 0;

  final List<int> taxOptions = [18, 12, 6];
  int selectedTax = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E9E9E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Add Item',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Item Details"),
              rowInputs([
                inputField("Item Code", itemCode),
                inputField("Description", description),
              ]),
              rowInputs([
                inputField("Unit of Measure", unitOfMeasure),
                inputField("Category", category),
              ]),
              rowInputs([
                inputField("Standard Packing Quantity", standardPackingQty),
                inputField("Minimum Order Quantity", minimumOrderQty),
              ]),
              rowInputs([
                inputField("Rate", rate),
                inputField("HSN", hsn),
              ]),

              const SizedBox(height: 16),
              sectionTitle("Quality Details"),
              rowInputs([
                Expanded(
                  child: preferenceTile("Supplier Test Report", supplierTestReport, (val) {
                    setState(() => supplierTestReport = val);
                  }),
                ),
                Expanded(
                  child: preferenceTile("IQC Batch Required", iqcBatch, (val) {
                    setState(() => iqcBatch = val);
                  }),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  controller: TextEditingController(text: iqcPercentage.toString()),
                  onChanged: (val) {
                    setState(() {
                      iqcPercentage = double.tryParse(val) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "IQC (%)",
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              sectionTitle("Tax"),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 10,
                  children: taxOptions.map((percent) {
                    final isSelected = selectedTax == percent;
                    return ChoiceChip(
                      label: Text("$percent%"),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => selectedTax = percent);
                      },
                      selectedColor: Colors.white,
                      backgroundColor: Colors.grey[800],
                      labelStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save
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
                  child: const Text('Save Item'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white38),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget rowInputs(List<Widget> children) {
    return Row(children: children);
  }

  Widget preferenceTile(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 72, 72, 72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
