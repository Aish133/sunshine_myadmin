import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController itemCode = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController standardPackingQty = TextEditingController();
  final TextEditingController minimumOrderQty = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController hsn = TextEditingController();

  String? selectedUnit;
  final List<String> unitOptions = ['pcs', 'kg', 'litre', 'mtr'];

  String? selectedCategory;
  final List<String> categoryOptions = ['Transistor', 'Resistor', 'Capacitor', 'PCB'];

  bool supplierTestReport = false;
  bool iqcBatch = false;
  double iqcPercentage = 0;

  final List<int> taxOptions = [18, 12, 6];
  int selectedTax = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                  dropdownField("Unit of Measure", unitOptions, selectedUnit, (val) {
                    setState(() => selectedUnit = val);
                  }),
                  dropdownField("Category", categoryOptions, selectedCategory, (val) {
                    setState(() => selectedCategory = val);
                  }),
                ]),
                rowInputs([
                  inputField("Standard Packing Quantity", standardPackingQty),
                  inputField("Minimum Order Quantity", minimumOrderQty),
                ]),
                rowInputs([
                  inputField("Rate", rate),
                  hsnField("HSN", hsn),
                ]),

                const SizedBox(height: 16),
                sectionTitle("Quality Details"),
                Row(
                  children: [
                    Expanded(
                      child: preferenceTile("Supplier Test Report", supplierTestReport, (val) {
                        setState(() => supplierTestReport = val);
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: preferenceTile("IQC Batch Required", iqcBatch, (val) {
                        setState(() => iqcBatch = val);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 16),
                  child: TextFormField(
                    initialValue: iqcPercentage.toInt().toString(),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed >= 1 && parsed <= 100) {
                        setState(() => iqcPercentage = parsed.toDouble());
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _MaxValueInputFormatter(100),
                    ],
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "IQC (%)",
                      labelStyle: const TextStyle(color: Colors.black87),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

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
                        selectedColor: Colors.black,
                        backgroundColor: Colors.grey[300],
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
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
          color: Colors.black,
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
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget hsnField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 8,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            counterText: '',
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    );
  }

  Widget dropdownField(String label, List<String> options, String? value, void Function(String?) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: options
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  ))
              .toList(),
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

class _MaxValueInputFormatter extends TextInputFormatter {
  final int max;

  _MaxValueInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int? value = int.tryParse(newValue.text);
    if (value != null && value > max) {
      return oldValue;
    }
    return newValue;
  }
}