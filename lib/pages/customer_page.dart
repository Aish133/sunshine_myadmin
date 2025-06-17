import 'package:flutter/material.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController primaryContact = TextEditingController();
  final TextEditingController primaryEmail = TextEditingController();
  final TextEditingController keyContact = TextEditingController();
  final TextEditingController keyEmail = TextEditingController();

  String? selectedDomain;
  final List<String> domainOptions = ['Infra', 'IT', 'IOT', 'Power'];

  final List<String> creditTypes = ['OPEN', 'PDC'];
  String selectedCreditType = 'OPEN';

  final List<int> paymentOptions = [0, 7, 30, 40, 60, 90, 120];
  int selectedPaymentDays = 30;

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
  void initState() {
    super.initState();
    addExtraAddress(); // start with one address
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
            sectionTitle("General Info"),
            rowInputs([
              inputField("Customer Name", nameController),
              dropdownField("Domain", domainOptions, selectedDomain, (val) {
                setState(() => selectedDomain = val);
              }),
            ]),
            const SizedBox(height: 16),
            sectionTitle("Addresses"),
            ...extraAddresses.asMap().entries.map((entry) {
              final index = entry.key;
              final address = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address ${index + 1}",
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  rowInputs([
                    inputField("Label (e.g., Home, Corporate)", address['label']!),
                  ]),
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
              icon: const Icon(Icons.add, color: Colors.black87),
              label: const Text("Add Address", style: TextStyle(color: Colors.black87)),
            ),
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
            const SizedBox(height: 16),
            sectionTitle("Preferences"),
            preferenceToggles(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
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
                child: const Text('Save Customer'),
              ),
            )
          ],
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
            labelStyle: const TextStyle(color: Colors.black54),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
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
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
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
            selectedColor: Colors.black,
            backgroundColor: Colors.grey[300],
            labelStyle: TextStyle(
              fontFamily: 'Roboto',
              color: isSelected ? Colors.white : Colors.black87,
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
            selectedColor: Colors.black,
            backgroundColor: Colors.grey[300],
            labelStyle: TextStyle(
              fontFamily: 'Roboto',
              color: isSelected ? Colors.white : Colors.black87,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget preferenceToggles() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: preferenceTile(
              "Email Notifications",
              emailNotification,
              (val) => setState(() => emailNotification = val),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: preferenceTile(
              "Account Status - Active/Disabled",
              isActive,
              (val) => setState(() => isActive = val),
            ),
          ),
        ),
      ],
    );
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