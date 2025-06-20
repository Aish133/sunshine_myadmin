import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceRequest extends StatefulWidget {
  const AttendanceRequest({Key? key}) : super(key: key);

  @override
  State<AttendanceRequest> createState() => _AttendanceRequestState();
}

class _AttendanceRequestState extends State<AttendanceRequest> {
  List<Map<String, dynamic>> attendanceRequests = [];
  String selectedFilter = 'all';
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceRequests();
  }

  Future<void> fetchAttendanceRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('https://www.sunshineagro.in/api/v1/hr_services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          attendanceRequests = List<Map<String, dynamic>>.from(data);
          attendanceRequests.sort((a, b) {
            final dateA = DateTime.parse(a['attendance_date'].split('-').reversed.join('-'));
            final dateB = DateTime.parse(b['attendance_date'].split('-').reversed.join('-'));
            return dateB.compareTo(dateA);
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance requests');
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

  Future<void> handleRequest(int serviceId, int action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/hr_services/rectify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'service_id': serviceId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 1 ? 'Request accepted' : 'Request rejected'),
            backgroundColor: action == 1 ? Colors.green : Colors.red,
          ),
        );
        fetchAttendanceRequests();
      } else {
        throw Exception('Failed to process request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String getServiceTypeText(int serviceType) {
    switch (serviceType) {
      case 4:
        return 'Extra Working Hour';
      case 3:
        return 'Work From Home';
      case 2:
        return 'Out Door Duty';
      case 1:
        return 'Applied for Missed Punch';
      default:
        return 'Missing Punch';
    }
  }

  List<Map<String, dynamic>> getFilteredRequests() {
    return attendanceRequests.where((request) {
      final matchesFilter = selectedFilter == 'all' ||
          request['service_type'].toString() == selectedFilter;
      final matchesSearch = searchQuery.isEmpty ||
          request['emp_id'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          request['emp_name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          request['attendance_date'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  List<Widget> buildFilterSearchFields(bool isWide) {
    return [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedFilter,
          decoration: const InputDecoration(
            labelText: 'Filter Requests',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Requests')),
            DropdownMenuItem(value: '4', child: Text('Extra Working Hours')),
            DropdownMenuItem(value: '3', child: Text('Work From Home')),
            DropdownMenuItem(value: '2', child: Text('Out Door Duty')),
            DropdownMenuItem(value: '1', child: Text('Applied for Missed Punch')),
          ],
          onChanged: (value) {
            setState(() {
              selectedFilter = value!;
            });
          },
        ),
      ),
      SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
      Expanded(
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isWide
                          ? Row(children: buildFilterSearchFields(isWide))
                          : Column(children: buildFilterSearchFields(isWide)),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: isWide ? 800 : 600),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Employee Name')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('In Time')),
                                DataColumn(label: Text('Out Time')),
                                DataColumn(label: Text('Service')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: getFilteredRequests().map((request) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(request['emp_id'].toString())),
                                    DataCell(Text(request['emp_name'])),
                                    DataCell(Text(request['attendance_date'])),
                                    DataCell(Text(request['in_time'])),
                                    DataCell(Text(request['out_time'])),
                                    DataCell(Text(getServiceTypeText(request['service_type']))),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => handleRequest(request['service_id'], 1),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => handleRequest(request['service_id'], 0),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    )),
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
            );
          },
        ),
      ),
    );
  }
}