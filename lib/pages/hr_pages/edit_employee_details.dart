import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowEmployeeDetails extends StatefulWidget {
  const ShowEmployeeDetails({Key? key}) : super(key: key);

  @override
  State<ShowEmployeeDetails> createState() => _ShowEmployeeDetailsState();
}

class _ShowEmployeeDetailsState extends State<ShowEmployeeDetails> {
  List<Employee> employees = [];
  bool isLoading = true;
  String? error;
  final TextEditingController searchController = TextEditingController();

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
        setState(() {
          error = 'Authentication token not found';
          isLoading = false;
        });
        return;
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
          employees = data.map((json) => Employee.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load employee details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String getDesignation(int designationCode) {
    switch (designationCode) {
      case 12:
        return "Management";
      case 11:
        return "CEO/MD";
      case 10:
        return "Business Unit/Department Head/Director";
      case 9:
        return "Sr Manager/Dept Head";
      case 8:
        return "Manager";
      case 7:
        return "Dy Manager";
      case 6:
        return "Asst Manager";
      case 5:
        return "Sr Executive";
      case 4:
        return "Engineer";
      case 3:
        return "Jr. Engineer";
      case 2:
        return "Trainee Engineer-GET";
      case 1:
        return "Associate Staff/Operator";
      default:
        return "Academic Trainee";
    }
  }

  List<Employee> get filteredEmployees {
    if (searchController.text.isEmpty) {
      return employees;
    }
    return employees.where((employee) {
      final searchLower = searchController.text.toLowerCase();
      return employee.empName.toLowerCase().contains(searchLower) ||
          employee.empId.toString().contains(searchLower) ||
          getDesignation(employee.empDesignation).toLowerCase().contains(searchLower);
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (error != null)
                  Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                else
                  SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      child: DataTable(
                        columnSpacing: 8,
                        horizontalMargin: 8,
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: 60,
                              child: Text('ID', textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              flex: 2,
                              child: Text('Employee Name', textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              flex: 2,
                              child: Text('Designation', textAlign: TextAlign.center),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 80,
                              child: Text('Actions', textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                        rows: filteredEmployees.map((employee) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: Text(
                                      employee.empId.toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(employee.empPassportSizePhoto),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          employee.empName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      getDesignation(employee.empDesignation),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      minimumSize: const Size(60, 36),
                                    ),
                                    onPressed: () async {
                                      // TODO: Implement edit functionality with PIN verification
                                      final pin = await showDialog<String>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Enter PIN'),
                                          content: TextField(
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter PIN',
                                            ),
                                            onSubmitted: (value) {
                                              Navigator.pop(context, value);
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, '2508');
                                              },
                                              child: const Text('Submit'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (pin == '2508') {
                                        // Navigate to edit page
                                        // TODO: Implement navigation to edit page
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Invalid PIN')),
                                        );
                                      }
                                    },
                                    child: const Text('Edit'),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Employee {
  final int empId;
  final String empName;
  final int empDesignation;
  final String empPassportSizePhoto;

  Employee({
    required this.empId,
    required this.empName,
    required this.empDesignation,
    required this.empPassportSizePhoto,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['emp_id'] ?? 0,
      empName: json['emp_name'] ?? '',
      empDesignation: json['emp_designation'] ?? 0,
      empPassportSizePhoto: json['emp_passport_size_photo'] ?? '',
    );
  }
}