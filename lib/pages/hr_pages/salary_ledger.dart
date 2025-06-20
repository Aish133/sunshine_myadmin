import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;

class SalaryLedger extends StatefulWidget {
  const SalaryLedger({Key? key}) : super(key: key);

  @override
  _SalaryLedgerState createState() => _SalaryLedgerState();
}

class _SalaryLedgerState extends State<SalaryLedger> {
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> transactions = [];
  String? selectedEmployeeId;
  DateTime? fromDate;
  DateTime? toDate;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Add this method to check authentication
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      _showError('Authentication token not found. Please login again.');
      // You might want to navigate to login page here
      return null;
    }
    return token;
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    // Set default dates to current month
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, 1);
    toDate = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _loadEmployees() async {
    setState(() => isLoading = true);
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://www.sunshineagro.in/api/v1/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Employee data received: $data');
        setState(() {
          employees = data.map((e) {
            final Map<String, dynamic> employee = Map<String, dynamic>.from(e);
            // Ensure emp_id and emp_name are strings and not null
            employee['emp_id'] = employee['emp_id']?.toString() ?? '';
            employee['emp_name'] = employee['emp_name']?.toString() ?? 'Unknown';
            return employee;
          }).toList();
        });
        print('Processed employees: $employees');
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to load employees');
      }
    } catch (e) {
      print('Error in _loadEmployees: $e');
      _showError('Error loading employees: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchLedgerData() async {
    print('Selected Employee ID: $selectedEmployeeId');
    print('From Date: $fromDate');
    print('To Date: $toDate');

    if (selectedEmployeeId == null || fromDate == null || toDate == null) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final String empId = selectedEmployeeId.toString();
      print('Formatted Employee ID: $empId');

      final requestBody = {
        'emp_id': empId,
        'from_date': DateFormat('yyyy-MM-dd').format(fromDate!),
        'to_date': DateFormat('yyyy-MM-dd').format(toDate!),
      };
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/ledger/fetch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Process all items except the last one (summary)
          transactions = data.take(data.length - 1).map((e) {
            final Map<String, dynamic> transaction = Map<String, dynamic>.from(e);
            // Ensure all fields are properly formatted
            transaction['transaction_date'] = transaction['transaction_date']?.toString() ?? '';
            transaction['transaction_remark'] = transaction['transaction_remark']?.toString() ?? '';
            transaction['transaction_type'] = transaction['transaction_type'] ?? 0;
            transaction['transaction_amount'] = transaction['transaction_amount'] ?? 0;
            return transaction;
          }).toList();

          // Add the summary as the last row
          if (data.isNotEmpty) {
            final summary = data.last;
            transactions.add({
              'transaction_date': 'Total',
              'transaction_type': -1, // Special type for summary
              'transaction_amount': summary['total'] ?? 0,
              'transaction_remark': 'Summary',
              'payable': summary['totalPayable'] ?? 0,
              'paid': summary['totalPaid'] ?? 0,
            });
          }
        });
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to fetch ledger data');
      }
    } catch (e) {
      print('Error in _fetchLedgerData: $e');
      _showError('Error fetching ledger data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addTransaction(Map<String, dynamic> transactionData) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/ledger'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(transactionData),
      );

      if (response.statusCode == 200) {
        _showSuccess('Transaction added successfully');
        _fetchLedgerData();
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to add transaction');
      }
    } catch (e) {
      _showError('Error adding transaction: $e');
    }
  }

  Future<void> _editTransaction(Map<String, dynamic> transactionData) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/ledger/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(transactionData),
      );

      if (response.statusCode == 200) {
        _showSuccess('Transaction updated successfully');
        _fetchLedgerData();
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to update transaction');
      }
    } catch (e) {
      _showError('Error updating transaction: $e');
    }
  }

  Future<void> _deleteTransaction(String transactionId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('https://www.sunshineagro.in/api/v1/ledger/delete/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _showSuccess('Transaction deleted successfully');
        _fetchLedgerData();
      } else if (response.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to delete transaction');
      }
    } catch (e) {
      _showError('Error deleting transaction: $e');
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Salary Ledger'];

      // Add headers
      sheet.appendRow(['Date', 'Payable', 'Paid', 'Remark']);

      // Add data
      for (var transaction in transactions) {
        if (transaction['transaction_type'] != -1) { // Skip summary row
          sheet.appendRow([
            transaction['transaction_date'] ?? '',
            transaction['transaction_type'] == 0 ? transaction['transaction_amount']?.toString() ?? '0' : '',
            transaction['transaction_type'] == 1 ? transaction['transaction_amount']?.toString() ?? '0' : '',
            transaction['transaction_remark'] ?? '',
          ]);
        }
      }

      // Add summary row
      final summary = transactions.lastWhere((t) => t['transaction_type'] == -1, orElse: () => {});
      if (summary.isNotEmpty) {
        sheet.appendRow(['']); // Empty row for spacing
        sheet.appendRow(['Total', summary['payable']?.toString() ?? '0', summary['paid']?.toString() ?? '0', 'Summary']);
      }

      // Get the employee name
      final selectedEmployee = employees.firstWhere(
        (emp) => emp['emp_id'].toString() == selectedEmployeeId,
        orElse: () => {'emp_name': 'Unknown'},
      );

      // Create filename
      final fileName = 'Salary_Ledger_${selectedEmployee['emp_name']}${DateFormat('yyyy-MM-dd').format(fromDate!)}_to${DateFormat('yyyy-MM-dd').format(toDate!)}.xlsx';

      // Convert Excel to bytes
      final bytes = excel.encode();
      if (bytes != null) {
        // Create a blob from the bytes
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        // Create an anchor element and trigger download
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        
        // Clean up
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      _showError('Error exporting to Excel: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedEmployeeId,
                      decoration: const InputDecoration(
                        labelText: 'Select Employee',
                        border: OutlineInputBorder(),
                      ),
                      items: employees.map((employee) {
                        final String empId = employee['emp_id']?.toString() ?? '';
                        final String empName = employee['emp_name']?.toString() ?? 'Unknown';
                        
                        if (empId.isEmpty) return null; // Skip invalid entries
                        
                        return DropdownMenuItem(
                          value: empId,
                          child: Text('$empId - $empName'),
                        );
                      }).where((item) => item != null).cast<DropdownMenuItem<String>>().toList(),
                      onChanged: (String? value) {
                        print('Selected value: $value');
                        if (value != null) {
                          setState(() {
                            selectedEmployeeId = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an employee';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'From Date',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => fromDate = date);
                              }
                            },
                            controller: TextEditingController(
                              text: fromDate != null
                                  ? DateFormat('yyyy-MM-dd').format(fromDate!)
                                  : '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'To Date',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => toDate = date);
                              }
                            },
                            controller: TextEditingController(
                              text: toDate != null
                                  ? DateFormat('yyyy-MM-dd').format(toDate!)
                                  : '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _fetchLedgerData,
                      child: Text(isLoading ? 'Loading...' : 'Check Ledgers'),
                    ),
                    if (selectedEmployeeId != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Show add transaction dialog
                          showDialog(
                            context: context,
                            builder: (context) => _AddTransactionDialog(
                              employeeId: selectedEmployeeId!,
                              onAdd: _addTransaction,
                            ),
                          );
                        },
                        child: const Text('Add Transaction'),
                      ),
                    ],
                    if (transactions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _exportToExcel,
                        child: const Text('Export to Excel'),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Payable')),
                            DataColumn(label: Text('Paid')),
                            DataColumn(label: Text('Remark')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: transactions.map((transaction) {
                            final bool isSummary = transaction['transaction_type'] == -1;
                            return DataRow(
                              cells: [
                                DataCell(Text(transaction['transaction_date'] ?? '')),
                                DataCell(Text(
                                  isSummary 
                                    ? transaction['payable']?.toString() ?? '0'
                                    : transaction['transaction_type'] == 0
                                        ? transaction['transaction_amount']?.toString() ?? '0'
                                        : '',
                                )),
                                DataCell(Text(
                                  isSummary
                                    ? transaction['paid']?.toString() ?? '0'
                                    : transaction['transaction_type'] == 1
                                        ? transaction['transaction_amount']?.toString() ?? '0'
                                        : '',
                                )),
                                DataCell(Text(transaction['transaction_remark'] ?? '')),
                                DataCell(isSummary 
                                  ? const SizedBox() // No actions for summary row
                                  : Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => _EditTransactionDialog(
                                                transaction: transaction,
                                                onEdit: _editTransaction,
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Confirm Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete this transaction?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteTransaction(
                                                          transaction['transaction_id']
                                                              .toString());
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  final String employeeId;
  final Function(Map<String, dynamic>) onAdd;

  const _AddTransactionDialog({
    Key? key,
    required this.employeeId,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? transactionDate;
  String? transactionType;
  final amountController = TextEditingController();
  final remarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Transaction Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => transactionDate = date);
                }
              },
              controller: TextEditingController(
                text: transactionDate != null
                    ? DateFormat('yyyy-MM-dd').format(transactionDate!)
                    : '',
              ),
              validator: (value) =>
                  transactionDate == null ? 'Please select a date' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: transactionType,
              decoration: const InputDecoration(
                labelText: 'Transaction Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '0', child: Text('PAYABLE')),
                DropdownMenuItem(value: '1', child: Text('PAID')),
              ],
              onChanged: (value) {
                setState(() => transactionType = value);
              },
              validator: (value) =>
                  value == null ? 'Please select a transaction type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter an amount' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: 'Remark',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a remark' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onAdd({
                'emp_id': widget.employeeId,
                'transaction_date':
                    DateFormat('yyyy-MM-dd').format(transactionDate!),
                'transaction_type': int.parse(transactionType!),
                'transaction_amount': double.parse(amountController.text),
                'transaction_remark': remarkController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditTransactionDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Function(Map<String, dynamic>) onEdit;

  const _EditTransactionDialog({
    Key? key,
    required this.transaction,
    required this.onEdit,
  }) : super(key: key);

  @override
  _EditTransactionDialogState createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime transactionDate;
  late String transactionType;
  late final TextEditingController amountController;
  late final TextEditingController remarkController;

  @override
  void initState() {
    super.initState();
    transactionDate = DateTime.parse(widget.transaction['transaction_date']);
    transactionType = widget.transaction['transaction_type'].toString();
    amountController = TextEditingController(
        text: widget.transaction['transaction_amount'].toString());
    remarkController =
        TextEditingController(text: widget.transaction['transaction_remark']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Transaction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Transaction Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: transactionDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => transactionDate = date);
                }
              },
              controller: TextEditingController(
                text: DateFormat('yyyy-MM-dd').format(transactionDate),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: transactionType,
              decoration: const InputDecoration(
                labelText: 'Transaction Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '0', child: Text('PAYABLE')),
                DropdownMenuItem(value: '1', child: Text('PAID')),
              ],
              onChanged: (value) {
                setState(() => transactionType = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter an amount' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: 'Remark',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a remark' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onEdit({
                'transaction_id': widget.transaction['transaction_id'],
                'emp_id': widget.transaction['emp_id'],
                'transaction_date':
                    DateFormat('yyyy-MM-dd').format(transactionDate),
                'transaction_type': int.parse(transactionType),
                'transaction_amount': double.parse(amountController.text),
                'transaction_remark': remarkController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}