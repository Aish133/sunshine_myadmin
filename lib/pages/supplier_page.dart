import 'package:flutter/material.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final TextEditingController companyName = TextEditingController();
  final TextEditingController shortNote = TextEditingController();
  final TextEditingController regLabel = TextEditingController();
  final TextEditingController regAddress = TextEditingController();
  final TextEditingController regCity = TextEditingController();
  final TextEditingController regStatePin = TextEditingController();
  final TextEditingController regGstin = TextEditingController();

  final TextEditingController primaryContact = TextEditingController();
  final TextEditingController primaryEmail = TextEditingController();
  final TextEditingController keyContact = TextEditingController();
  final TextEditingController keyEmail = TextEditingController();

  String? selectedType;
  String? selectedCategory;
  final List<String> typeOptions = ['Company', 'Individual'];
  final List<String> categoryOptions = ['Manufacturer', 'Trader', 'Service'];

  String selectedCreditType = 'Open';
  final List<String> creditTypes = ['Open', 'PDC'];

  int selectedPaymentDays = 30;
  final List<int> paymentOptions = [0, 7, 30, 45, 60, 90, 120];

  bool auditApplicable = false;
  bool isMSME = false;
  bool emailNotification = false;
  bool isActive = true;

  List<Map<String, TextEditingController>> extraAddresses = [];

  void addExtraAddress() {
    setState(() {
      extraAddresses.add({
        'label': TextEditingController(),
        'address': TextEditingController(),
        'city': TextEditingController(),
        'state': TextEditingController(),
        'gstin': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          sectionTitle("Basic Info"),
          rowInputs([
            inputField("Company Name", companyName),
            dropdownField("Type", typeOptions, selectedType, (val) {
              setState(() => selectedType = val);
            }),
          ]),
          rowInputs([
            dropdownField("Category", categoryOptions, selectedCategory, (val) {
              setState(() => selectedCategory = val);
            }),
            inputField("Short Note", shortNote),
          ]),

          sectionTitle("Registration Address"),
          rowInputs([inputField("Label (e.g. Home, Office)", regLabel)]),
          rowInputs([inputField("Address", regAddress)]),
          rowInputs([
            inputField("City", regCity),
            inputField("State/Pin", regStatePin),
          ]),
          rowInputs([inputField("GSTIN/No", regGstin)]),

          sectionTitle("Additional Addresses"),
          ...extraAddresses.asMap().entries.map((entry) {
            final index = entry.key;
            final address = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 4.0, left: 8.0),
                  child: Text("Address ${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                rowInputs([inputField("Label", address['label']!)]),
                rowInputs([
                  inputField("Address", address['address']!),
                  inputField("City", address['city']!),
                ]),
                rowInputs([
                  inputField("State/Pin", address['state']!),
                  inputField("GSTIN", address['gstin']!),
                ]),
                const SizedBox(height: 10),
              ],
            );
          }),
          TextButton.icon(
            onPressed: addExtraAddress,
            icon: const Icon(Icons.add, color: Colors.black54),
            label: const Text("Add Address", style: TextStyle(color: Colors.black54)),
          ),

          sectionTitle("Audit / MSME Info"),
          Row(
            children: [
              Expanded(child: toggleSwitch("Audit Applicable", auditApplicable, (val) {
                setState(() => auditApplicable = val);
              })),
              const SizedBox(width: 12),
              Expanded(child: toggleSwitch("MSME", isMSME, (val) {
                setState(() => isMSME = val);
              })),
            ],
          ),

          sectionTitle("Contact Info"),
          rowInputs([
            inputField("Primary Contact", primaryContact),
            inputField("Primary Email", primaryEmail),
          ]),
          rowInputs([
            inputField("Key Contact", keyContact),
            inputField("Key Email ID", keyEmail),
          ]),

          sectionTitle("Payment Info"),
          creditTypeSelector(),
          paymentTermsSelector(),

          sectionTitle("Preferences"),
          Row(
            children: [
              Expanded(child: toggleSwitch("Email Notification", emailNotification, (val) {
                setState(() => emailNotification = val);
              })),
              const SizedBox(width: 12),
              Expanded(child: toggleSwitch("Status (Active/Disabled)", isActive, (val) {
                setState(() => isActive = val);
              })),
            ],
          ),

          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Save Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[100],
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

  Widget dropdownField(String label, List<String> options, String? value, void Function(String?) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        ),
      ),
    );
  }

  Widget rowInputs(List<Widget> children) => Row(children: children);

  Widget toggleSwitch(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.black),
        ],
      ),
    );
  }

  Widget creditTypeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 10,
        children: creditTypes.map((type) {
          final isSelected = selectedCreditType == type;
          return ChoiceChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedCreditType = type),
            selectedColor: Colors.black,
            backgroundColor: Colors.grey[300],
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        }).toList(),
      ),
    );
  }

  Widget paymentTermsSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 10,
        children: paymentOptions.map((day) {
          final isSelected = selectedPaymentDays == day;
          return ChoiceChip(
            label: Text("$day Days"),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedPaymentDays = day),
            selectedColor: Colors.black,
            backgroundColor: Colors.grey[300],
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        }).toList(),
      ),
    );
  }
}