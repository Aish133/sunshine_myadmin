import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdvanceLedger extends StatefulWidget {
  const AdvanceLedger({Key? key}) : super(key: key);

  @override
  _AdvanceLedgerState createState() => _AdvanceLedgerState();
}

class _AdvanceLedgerState extends State<AdvanceLedger> {
  String? selectedEmployeeId;
  DateTime? fromDate;
  DateTime? toDate;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> employees = [];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set default dates to current month
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, 1);
    toDate = DateTime(now.year, now.month + 1, 0);
    fetchEmployees();
  }

  Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> fetchEmployees() async {
    setState(() => isLoading = true);
    try {
      final token = await getJwtToken();
      final response = await http.get(
        Uri.parse('https://www.sunshineagro.in/api/v1/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          employees = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch employees')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTransactions() async {
    if (selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final token = await getJwtToken();
      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/advance/fetch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'emp_id': selectedEmployeeId,
          'from_date': DateFormat('yyyy-MM-dd').format(fromDate!),
          'to_date': DateFormat('yyyy-MM-dd').format(toDate!),
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          transactions = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch transactions')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate! : toDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Employee Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedEmployeeId,
                      decoration: const InputDecoration(
                        labelText: 'Select Employee',
                        border: OutlineInputBorder(),
                      ),
                      items: employees.map((employee) {
                        return DropdownMenuItem<String>(
                          value: employee['emp_id'].toString(),
                          child: Text('${employee['emp_id']} - ${employee['emp_name']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEmployeeId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Range Selection
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectDate(context, true),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              'From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}',
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _selectDate(context, false),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              'To: ${DateFormat('yyyy-MM-dd').format(toDate!)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isLoading ? null : fetchTransactions,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Check Ledgers'),
                    ),
                    const SizedBox(height: 16),

                    // Transactions Table
                    if (transactions.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Advance Given')),
                            DataColumn(label: Text('Advance Returned')),
                            DataColumn(label: Text('Remark')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: transactions.map((transaction) {
                            return DataRow(
                              cells: [
                                DataCell(Text(transaction['transaction_date'])),
                                DataCell(Text(
                                  transaction['transaction_type'] == 0
                                      ? transaction['transaction_amount'].toString()
                                      : '-',
                                )),
                                DataCell(Text(
                                  transaction['transaction_type'] == 1
                                      ? transaction['transaction_amount'].toString()
                                      : '-',
                                )),
                                DataCell(Text(transaction['transaction_remark'])),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // TODO: Implement edit functionality
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        // TODO: Implement delete functionality
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: selectedEmployeeId != null
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implement add transaction functionality
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}