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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E9E9E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Supplier Form',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
          ),
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

              const SizedBox(height: 16),
              sectionTitle("Registration Address"),
              rowInputs([
                inputField("Label (e.g. Home, Office)", regLabel),
              ]),
              rowInputs([
                inputField("Address", regAddress),
              ]),
              rowInputs([
                inputField("City", regCity),
                inputField("State/Pin", regStatePin),
              ]),
              rowInputs([
                inputField("GSTIN/No", regGstin),
              ]),

              const SizedBox(height: 16),
              sectionTitle("Audit / MSME Info"),
              toggleSwitch("Audit Applicable", auditApplicable, (val) {
                setState(() => auditApplicable = val);
              }),
              toggleSwitch("MSME", isMSME, (val) {
                setState(() => isMSME = val);
              }),

              const SizedBox(height: 16),
              sectionTitle("Contact Info"),
              rowInputs([
                inputField("Primary Contact", primaryContact),
                inputField("Primary Email", primaryEmail),
              ]),
              rowInputs([
                inputField("Key Contact", keyContact),
                inputField("Key Email ID", keyEmail),
              ]),

              const SizedBox(height: 16),
              sectionTitle("Payment Info"),
              creditTypeSelector(),
              paymentTermsSelector(),

              const SizedBox(height: 12),
              sectionTitle("Preferences"),
              toggleSwitch("Email Notification", emailNotification, (val) {
                setState(() => emailNotification = val);
              }),
              toggleSwitch("Status (Active/Disabled)", isActive, (val) {
                setState(() => isActive = val);
              }),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text(
                    'Save Supplier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
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
            filled: true,
            fillColor: const Color(0xFF3A3A3A),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
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

  Widget dropdownField(String label, List<String> options, String? value, void Function(String?) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF3A3A3A),
            border: OutlineInputBorder(
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

  Widget toggleSwitch(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
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
            onSelected: (_) {
              setState(() => selectedCreditType = type);
            },
            selectedColor: Colors.white,
            backgroundColor: Colors.grey[800],
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
            ),
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
            onSelected: (_) {
              setState(() => selectedPaymentDays = day);
            },
            selectedColor: Colors.white,
            backgroundColor: Colors.grey[800],
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
