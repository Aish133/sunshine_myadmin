import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDetails extends StatefulWidget {
  const EmployeeDetails({Key? key}) : super(key: key);

  @override
  State<EmployeeDetails> createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
  }

  Future<void> fetchEmployeeDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

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
          employees = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load employee details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String getDesignationText(dynamic designationId) {
    // Convert designationId to string for comparison
    String id = designationId.toString();
    switch (id) {
      case '12':
        return "Management";
      case '11':
        return "CEO/MD";
      case '10':
        return "Business Unit/Department Head/Director";
      case '9':
        return "Sr Manager/Dept Head";
      case '8':
        return "Manager";
      case '7':
        return "Dy Manager";
      case '6':
        return "Asst Manager";
      case '5':
        return "Sr Executive";
      case '4':
        return "Engineer";
      case '3':
        return "Jr. Engineer";
      case '2':
        return "Trainee Engineer-GET";
      case '1':
        return "Associate Staff/Operator";
      default:
        return "Academic Trainee";
    }
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void showEmployeeDetailsModal(BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Employee Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(employee['emp_passport_size_photo'] ?? ''),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('ID', employee['emp_id']),
                _buildDetailRow('Name', employee['emp_name']),
                _buildDetailRow('Designation', getDesignationText(employee['emp_designation'])),
                _buildDetailRow('Phone', employee['emp_phone_no']),
                _buildDetailRow('Email', employee['emp_email_id']),
                _buildDetailRow('Address', employee['emp_current_address']),
                _buildDetailRow('Date of Birth', formatDate(employee['emp_dob'])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get filteredEmployees {
    if (searchQuery.isEmpty) {
      return employees;
    }
    return employees.where((employee) {
      final name = employee['emp_name'].toString().toLowerCase();
      final id = employee['emp_id'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          id.contains(searchQuery.toLowerCase());
    }).toList();
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: filteredEmployees.map((employee) {
                          return DataRow(
                            cells: [
                              DataCell(Text(employee['emp_id'].toString())),
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                        employee['emp_passport_size_photo'] ?? '',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(employee['emp_name']),
                                  ],
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () => showEmployeeDetailsModal(
                                    context,
                                    employee,
                                  ),
                                  child: const Text('View'),
                                ),
                              ),
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
    );
  }
}