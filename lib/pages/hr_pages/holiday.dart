import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Holiday {
  final String holidayDate;
  final String holidayName;
  final String holidayDescription;
  final String remarks;

  Holiday({
    required this.holidayDate,
    required this.holidayName,
    required this.holidayDescription,
    required this.remarks,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      holidayDate: json['holiday_date'],
      holidayName: json['holiday_name'],
      holidayDescription: json['holiday_description'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holiday_date': holidayDate,
      'holiday_name': holidayName,
      'holiday_description': holidayDescription,
      'remarks': remarks,
    };
  }
}

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({Key? key}) : super(key: key);

  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  List<Holiday> holidays = [];
  DateTime currentDate = DateTime.now();
  bool isLoading = true;
  String? jwtToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jwtToken = prefs.getString('jwt_token');
    });
    if (jwtToken != null) {
      await fetchHolidays();
    }
  }

  Future<void> fetchHolidays() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.sunshineagro.in/api/v1/holidays'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          holidays = data.map((json) => Holiday.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load holidays');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading holidays: $e')),
      );
    }
  }

  Future<void> addHoliday(Holiday holiday) async {
    try {
      final response = await http.post(
        Uri.parse('https://www.sunshineagro.in/api/v1/holidays'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(holiday.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchHolidays();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Holiday added successfully')),
        );
      } else {
        throw Exception('Failed to add holiday');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding holiday: $e')),
      );
    }
  }

  Future<void> deleteHoliday(String date) async {
    try {
      final response = await http.delete(
        Uri.parse('https://www.sunshineagro.in/api/v1/holidays'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode([{'holiday_date': date}]),
      );

      if (response.statusCode == 200) {
        await fetchHolidays();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Holiday deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete holiday');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting holiday: $e')),
      );
    }
  }

  void _showAddHolidayDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Holiday'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Holiday Title',
                  hintText: 'Enter holiday title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter holiday description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: const Text('Select Date'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
              final holiday = Holiday(
                holidayDate: formattedDate,
                holidayName: titleController.text,
                holidayDescription: descriptionController.text,
                remarks: '',
              );
              addHoliday(holiday);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Holidays',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showAddHolidayDialog,
                        child: const Text('Add Holiday'),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidays[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(holiday.holidayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${holiday.holidayDate}'),
                              if (holiday.holidayDescription.isNotEmpty)
                                Text(holiday.holidayDescription),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteHoliday(holiday.holidayDate),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}