import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddEmployee extends StatefulWidget {
  const AddEmployee({Key? key}) : super(key: key);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _formKey = GlobalKey<FormState>();
  bool _mounted = true;
  bool _isLoading = false;
  int _currentStep = 0;

  // Form controllers
  final _empIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telegramIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emeContact01Controller = TextEditingController();
  final _emeContact02Controller = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _passportController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _ifscController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _salaryController = TextEditingController();
  final _otRateController = TextEditingController();
  final _noOfLeavesController = TextEditingController();
  final _sundayController = TextEditingController();
  final _odAllowanceController = TextEditingController();
  final _lateMarkController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _contractorController = TextEditingController();
  final _empPfController = TextEditingController();
  final _empEsiController = TextEditingController();
  final _petrolAllowanceController = TextEditingController();
  final _mobileAllowanceController = TextEditingController();
  final _kidEduAllowanceController = TextEditingController();
  final _variableController = TextEditingController();
  final _noteController = TextEditingController();

  // Date fields
  DateTime? _dob;
  DateTime? _doc;
  DateTime? _passportExpiry;
  DateTime? _doj;

  // Dropdown values with non-null initial values
  String _bloodGroup = 'Select Option';
  String _qualification = 'Select Option';
  String _level = 'Select Option';
  String _reportingTo = 'Select Option';
  String _position = 'Select Option';
  String _dept = 'Select Option';
  String _punch = 'Select Option';
  String _salaryType = 'Select Option';
  String _ot = 'Select Option';
  String _leaves = 'Select Option';
  String _wfh = 'Select Option';
  String _od = 'Select Option';
  String _empActive = 'Select Option';
  String _userType = 'Select Option';

  // Image files
  XFile? _passportPhoto;
  XFile? _fullPhoto;
  String? _passportPhotoUrl;
  String? _fullPhotoUrl;

  List<String> _reportingToList = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchReportingToList();
  }

  @override
  void dispose() {
    _mounted = false;
    _empIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _telegramIdController.dispose();
    _phoneController.dispose();
    _emeContact01Controller.dispose();
    _emeContact02Controller.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _drivingLicenseController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _passportController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _medicalHistoryController.dispose();
    _salaryController.dispose();
    _otRateController.dispose();
    _noOfLeavesController.dispose();
    _odAllowanceController.dispose();
    _contractorController.dispose();
    _sundayController.dispose();
    _lateMarkController.dispose();
    _workingHoursController.dispose();
    _empPfController.dispose();
    _empEsiController.dispose();
    _petrolAllowanceController.dispose();
    _mobileAllowanceController.dispose();
    _kidEduAllowanceController.dispose();
    _variableController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchReportingToList() async {
    if (!_mounted) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      final response = await http.get(
        Uri.parse('https://www.sunshineagro.in/api/v1/employee/reporting_to'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!_mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _reportingToList = data.map((e) => e.toString()).toList();
          if (_reportingToList.isNotEmpty) {
            _reportingTo = _reportingToList.first;
          }
        });
      }
    } catch (e) {
      if (!_mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reporting list: $e')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source, bool isPassport) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        // For web, we'll use a temporary URL
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          setState(() {
            if (isPassport) {
              _passportPhotoUrl = 'data:image/jpeg;base64,$base64Image';
            } else {
              _fullPhotoUrl = 'data:image/jpeg;base64,$base64Image';
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImagePickerOptions(bool isPassport) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isPassport);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isPassport);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(String? imageUrl) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red,
          );
        },
      );
    }
    return const Icon(
      Icons.add_a_photo,
      size: 50,
      color: Colors.grey,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (!_mounted) return;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://www.sunshineagro.in/api/v1/employee'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add form fields
      final Map<String, String> formFields = {
        'emp_id': _empIdController.text,
        'emp_name': _nameController.text,
        'emp_email_id': _emailController.text,
        'emp_telegram_id': _telegramIdController.text,
        'emp_phone_number': _phoneController.text,
        'emp_emergency_no_01': _emeContact01Controller.text,
        'emp_emergency_no_02': _emeContact02Controller.text,
        'emp_aadhar': _aadharController.text,
        'emp_pan': _panController.text,
        'emp_driving_license': _drivingLicenseController.text,
        'emp_current_address': _currentAddressController.text,
        'emp_permanent_address': _permanentAddressController.text,
        'emp_bod': _dob?.toIso8601String() ?? '',
        'emp_docel': _doc?.toIso8601String() ?? '',
        'emp_blood_group': _bloodGroup,
        'emp_qualification': _qualification,
        'emp_passport_no': _passportController.text,
        'emp_passport_valid_till': _passportExpiry?.toIso8601String() ?? '',
        'emp_bank_name': _bankNameController.text,
        'emp_bank_account': _accountNumberController.text,
        'emp_bank_branch': _bankBranchController.text,
        'emp_bank_ifsc': _ifscController.text,
        'emp_date_of_joining': _doj?.toIso8601String() ?? '',
        'emp_medical_history': _medicalHistoryController.text,
        'emp_designation': _level,
        'emp_reporting_to': _reportingTo,
        'emp_position': _position,
        'emp_is_punch_allowed': _punch,
        'emp_salary_type': _salaryType,
        'emp_salary': _salaryController.text,
        'emp_is_ot_applicable': _ot,
        'emp_ot_rate': _otRateController.text,
        'emp_no_leaves': _noOfLeavesController.text,
        'emp_sunday_working': _sundayController.text,
        'emp_work_from_home': _wfh,
        'emp_od': _od,
        'emp_od_allowance_per_day': _odAllowanceController.text,
        'emp_latemark': _lateMarkController.text,
        'emp_working_hours': _workingHoursController.text,
        'emp_working_full_day': _dept,
        'emp_half_day': _contractorController.text,
        'emp_access_control': _userType,
        'emp_pf_no': _empPfController.text,
        'emp_esic_no': _empEsiController.text,
        'emp_petrol_allowance': _petrolAllowanceController.text,
        'emp_mobile_allowance': _mobileAllowanceController.text,
        'emp_kid_education': _kidEduAllowanceController.text,
        'emp_variable': _variableController.text,
        'emp_active_status': _empActive,
        'emp_note': _noteController.text,
      };

      request.fields.addAll(formFields);

      // Handle image uploads for web
      if (kIsWeb) {
        if (_passportPhotoUrl != null) {
          final base64Data = _passportPhotoUrl!.split(',')[1];
          final bytes = base64Decode(base64Data);
          request.files.add(
            http.MultipartFile.fromBytes(
              'emp_passport_size_photo',
              bytes,
              filename: 'passport_photo.jpg',
            ),
          );
        }
        if (_fullPhotoUrl != null) {
          final base64Data = _fullPhotoUrl!.split(',')[1];
          final bytes = base64Decode(base64Data);
          request.files.add(
            http.MultipartFile.fromBytes(
              'emp_full_view_photo',
              bytes,
              filename: 'full_photo.jpg',
            ),
          );
        }
      } else {
        // Handle image uploads for mobile
        if (_passportPhoto != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'emp_passport_size_photo',
              _passportPhoto!.path,
            ),
          );
        }
        if (_fullPhoto != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'emp_full_view_photo',
              _fullPhoto!.path,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!_mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding employee')),
        );
      }
    } catch (e) {
      if (!_mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (_mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateDropdownValue(String? newValue, String field) {
    if (newValue != null) {
      setState(() {
        switch (field) {
          case 'bloodGroup':
            _bloodGroup = newValue;
            break;
          case 'qualification':
            _qualification = newValue;
            break;
          case 'level':
            _level = newValue;
            break;
          case 'reportingTo':
            _reportingTo = newValue;
            break;
          case 'position':
            _position = newValue;
            if (newValue == 'Contract Based') {
              _contractorController.text = '';
            }
            break;
          case 'dept':
            _dept = newValue;
            break;
          case 'punch':
            _punch = newValue;
            break;
          case 'salaryType':
            _salaryType = newValue;
            break;
          case 'ot':
            _ot = newValue;
            break;
          case 'leaves':
            _leaves = newValue;
            break;
          case 'wfh':
            _wfh = newValue;
            break;
          case 'od':
            _od = newValue;
            break;
          case 'empActive':
            _empActive = newValue;
            break;
          case 'userType':
            _userType = newValue;
            break;
        }
      });
    }
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required String field,
    bool isRequired = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) => _updateDropdownValue(newValue, field),
      validator: isRequired
          ? (value) {
              if (value == 'Select Option') {
                return 'Please select $label';
              }
              return null;
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) return false;
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 5) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      _submitForm();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(_currentStep == 5 ? 'Submit' : 'Next'),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Back'),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Personal Information'),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _empIdController,
                            decoration: const InputDecoration(labelText: 'Employee ID *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter employee ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Name *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telegramIdController,
                            decoration: const InputDecoration(labelText: 'Telegram Chat ID *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Telegram Chat ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emeContact01Controller,
                            decoration: const InputDecoration(labelText: 'Emergency Contact Number(01) *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter emergency contact number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emeContact02Controller,
                            decoration: const InputDecoration(labelText: 'Emergency Contact Number(02)'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _aadharController,
                            decoration: const InputDecoration(labelText: 'Aadhar Card No. *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Aadhar number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _panController,
                            decoration: const InputDecoration(labelText: 'Pan Card No.'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _drivingLicenseController,
                            decoration: const InputDecoration(labelText: 'Driving License No. *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter driving license number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _currentAddressController,
                            decoration: const InputDecoration(labelText: 'Current Address *'),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter current address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _permanentAddressController,
                            decoration: const InputDecoration(labelText: 'Permanent Address *'),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter permanent address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Date of Birth *'),
                            subtitle: Text(_dob == null ? 'Select Date' : _dob.toString().split(' ')[0]),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _dob ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _dob = picked;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Date of Celebration *'),
                            subtitle: Text(_doc == null ? 'Select Date' : _doc.toString().split(' ')[0]),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _doc ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _doc = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Additional Information'),
                      content: Column(
                        children: [
                          _buildDropdown(
                            value: _bloodGroup,
                            label: 'Blood Group',
                            items: [
                              'Select Option',
                              'A+',
                              'A-',
                              'B+',
                              'B-',
                              'AB+',
                              'AB-',
                              'O+',
                              'O-',
                            ],
                            field: 'bloodGroup',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _qualification,
                            label: 'Qualification',
                            items: [
                              'Select Option',
                              'M.E/M.Tech',
                              'B.E/B.Tech',
                              'MBA',
                              'Diploma',
                              'B.A/B.SC/B.COM',
                              '12th/ITI',
                              '10th',
                            ],
                            field: 'qualification',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passportController,
                            decoration: const InputDecoration(labelText: 'Passport No.'),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Passport Expiry Date'),
                            subtitle: Text(_passportExpiry == null ? 'Select Date' : _passportExpiry.toString().split(' ')[0]),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _passportExpiry ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _passportExpiry = picked;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bankNameController,
                            decoration: const InputDecoration(labelText: 'Bank Name *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter bank name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bankBranchController,
                            decoration: const InputDecoration(labelText: 'Bank Branch Name *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter bank branch name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _accountNumberController,
                            decoration: const InputDecoration(labelText: 'Account Number *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter account number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ifscController,
                            decoration: const InputDecoration(labelText: 'IFSC Number *'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter IFSC number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Date of Joining *'),
                            subtitle: Text(_doj == null ? 'Select Date' : _doj.toString().split(' ')[0]),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _doj ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _doj = picked;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _medicalHistoryController,
                            decoration: const InputDecoration(labelText: 'Medical History *'),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter medical history';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Professional Information'),
                      content: Column(
                        children: [
                          _buildDropdown(
                            value: _level,
                            label: 'Level/Designation',
                            items: [
                              'Select Option',
                              'Level 12 - Management',
                              'Level 11 - CEO/MD',
                              'Level 10 - Business Unit/Department Head/Director',
                              'Level 09 - Sr Manager/Dept Head',
                              'Level 08 - Manager',
                              'Level 07 - Dy Manager',
                              'Level 06 - Asst Manager',
                              'Level 05 - Sr Engineer',
                              'Level 04 - Engineer',
                              'Level 03 - Jr. Engineer',
                              'Level 02 - Trainee Engineer-GET',
                              'Level 01 - Associate Staff',
                              'Level 00 - Academic Trainee',
                            ],
                            field: 'level',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _reportingTo,
                            label: 'Reporting To',
                            items: _reportingToList,
                            field: 'reportingTo',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _position,
                            label: 'Position',
                            items: [
                              'Select Option',
                              'Permanent',
                              'Contract Based',
                              'Intern',
                              'Part Time',
                              'Consultant',
                            ],
                            field: 'position',
                          ),
                          if (_position == 'Contract Based') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contractorController,
                              decoration: const InputDecoration(labelText: 'Contractor *'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contractor name';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _dept,
                            label: 'Department',
                            items: [
                              'Select Option',
                              'Management',
                              'Quality',
                              'Production',
                              'Testing',
                              'Service',
                              'HR',
                              'Account',
                              'Support',
                              'Admin',
                              'CDG',
                              'SCM',
                            ],
                            field: 'dept',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _punch,
                            label: 'Punch',
                            items: [
                              'Select Option',
                              'Mandatory',
                              'Not Mandatory',
                            ],
                            field: 'punch',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _salaryType,
                            label: 'Salary Type',
                            items: [
                              'Select Option',
                              'Monthly',
                              'Hourly',
                            ],
                            field: 'salaryType',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _salaryController,
                            decoration: const InputDecoration(labelText: 'Salary *'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter salary';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _ot,
                            label: 'OT Applicable',
                            items: [
                              'Select Option',
                              'Yes',
                              'No',
                            ],
                            field: 'ot',
                          ),
                          if (_ot == 'Yes') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _otRateController,
                              decoration: const InputDecoration(labelText: 'OT Rate(%) *'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter OT rate';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _leaves,
                            label: 'Accountable for Leaves',
                            items: [
                              'Select Option',
                              'Yes',
                              'No',
                            ],
                            field: 'leaves',
                          ),
                          if (_leaves == 'Yes') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _noOfLeavesController,
                              decoration: const InputDecoration(labelText: 'No of Leaves *'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of leaves';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _sundayController,
                            decoration: const InputDecoration(labelText: 'Sunday Working *'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter sunday working hours';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _wfh,
                            label: 'Work from Home',
                            items: [
                              'Select Option',
                              'Yes',
                              'No',
                            ],
                            field: 'wfh',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _od,
                            label: 'OD Allowed',
                            items: [
                              'Select Option',
                              'Yes',
                              'No',
                            ],
                            field: 'od',
                          ),
                          if (_od == 'Yes') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _odAllowanceController,
                              decoration: const InputDecoration(labelText: 'OD Allowance Per Day'),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lateMarkController,
                            decoration: const InputDecoration(labelText: 'Late Mark (Min) *'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter late mark minutes';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _workingHoursController,
                            decoration: const InputDecoration(labelText: 'Working Hours *'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter working hours';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _empPfController,
                            decoration: const InputDecoration(labelText: 'Employee PF Number *'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter PF number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _empEsiController,
                            decoration: const InputDecoration(labelText: 'Employee ESI Number *'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter ESI number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Allowance Information'),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _petrolAllowanceController,
                            decoration: const InputDecoration(labelText: 'Petrol Allowance(Monthly)'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mobileAllowanceController,
                            decoration: const InputDecoration(labelText: 'Mobile Allowance(Monthly)'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _kidEduAllowanceController,
                            decoration: const InputDecoration(labelText: 'Kid Education Allowance(Yearly)'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _variableController,
                            decoration: const InputDecoration(labelText: 'Employee Variable'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _empActive,
                            label: 'Employee Active',
                            items: [
                              'Select Option',
                              'Yes',
                              'No',
                            ],
                            field: 'empActive',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(labelText: 'Note'),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _userType,
                            label: 'User Type',
                            items: [
                              'Select Option',
                              'Admin/HR',
                              'User',
                            ],
                            field: 'userType',
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Images'),
                      content: Column(
                        children: [
                          const Text(
                            'Passport Size Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _showImagePickerOptions(true),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildImagePreview(_passportPhotoUrl),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Full Size Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _showImagePickerOptions(false),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildImagePreview(_fullPhotoUrl),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Review'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Employee ID: ${_empIdController.text}'),
                          Text('Name: ${_nameController.text}'),
                          Text('Email: ${_emailController.text}'),
                          Text('Phone: ${_phoneController.text}'),
                          const SizedBox(height: 16),
                          const Text('Professional Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Designation: $_level'),
                          Text('Department: $_dept'),
                          Text('Position: $_position'),
                          Text('Salary: ${_salaryController.text}'),
                          const SizedBox(height: 16),
                          const Text('Additional Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Blood Group: $_bloodGroup'),
                          Text('Qualification: $_qualification'),
                          Text('Date of Joining: ${_doj?.toString().split(' ')[0]}'),
                          const SizedBox(height: 16),
                          const Text('Allowance Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Petrol Allowance: ${_petrolAllowanceController.text}'),
                          Text('Mobile Allowance: ${_mobileAllowanceController.text}'),
                          Text('Kid Education Allowance: ${_kidEduAllowanceController.text}'),
                          const SizedBox(height: 16),
                          const Text('Images', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              if (_passportPhoto != null)
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Passport Photo'),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_passportPhoto!.path),
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_fullPhoto != null)
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Full Photo'),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_fullPhoto!.path),
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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