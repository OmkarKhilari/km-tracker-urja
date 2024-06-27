import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:km_tracker/widgets/loading_screen.dart';

class EmployeeData {
  final String name;
  final String designation;
  final String branch;

  EmployeeData({
    required this.name,
    required this.designation,
    required this.branch,
  });
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  File? _selfieImage;
  bool _isImageCaptured = false;
  List<EmployeeData> _employeeData = [];
  List<String> _names = [];
  String? _selectedBranch;
  String? _selectedDesignation;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
    _isLoading.value = true;
    QuerySnapshot snapshot = await firestore.collection('employees').get();
    List<EmployeeData> data = snapshot.docs.map((doc) {
      return EmployeeData(
        name: doc['name'],
        designation: doc['designation'],
        branch: doc['branch'],
      );
    }).toList();
    setState(() {
      _employeeData = data;
      _isLoading.value = false;
    });
  }

  void _updateNames() {
    setState(() {
      _names = _employeeData
          .where((employee) =>
              employee.branch == _selectedBranch &&
              employee.designation == _selectedDesignation)
          .map((employee) => employee.name)
          .toList();
    });
  }

  Future<void> _captureSelfie() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selfieImage = File(image.path);
        _isImageCaptured = true;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_formKey.currentState!.saveAndValidate() && _isImageCaptured) {
      final formData = _formKey.currentState!.value;
      final branch = formData['branch'];
      final designation = formData['designation'];
      final name = formData['name'];

      final Map<String, dynamic> data = {
        'branch': branch,
        'designation': designation,
        'name': name,
        'attendance': 'Present',
      };

      _isLoading.value = true;

      final response = await http.post(
        Uri.parse('https://omkar.bhaskaraa45.me/attendance/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      _isLoading.value = false;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark attendance.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form and capture a selfie.')),
      );
    }
  }

  void _saveData() {
    _formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        return LoadingScreen(
          isLoading: isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Mark Attendance'),
              backgroundColor: Colors.green.shade700,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FormBuilderDropdown(
                        name: 'branch',
                        decoration: InputDecoration(
                          labelText: 'Select Branch',
                          hintText: 'Select Branch',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _formKey.currentState!.fields['branch']!.reset();
                              setState(() {
                                _names = [];
                              });
                              _saveData();
                            },
                          ),
                        ),
                        items: ['Manchar', 'Alephata', 'Urulikanchan', 'Shirur', 'Sangamner', 'Nirgudsar']
                            .map((branch) => DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedBranch = value;
                            _updateNames();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderDropdown(
                        name: 'designation',
                        decoration: InputDecoration(
                          labelText: 'Select Designation',
                          hintText: 'Select Designation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _formKey.currentState!.fields['designation']!.reset();
                              setState(() {
                                _names = [];
                              });
                              _saveData();
                            },
                          ),
                        ),
                        items: ['Sr. Manager', 'BM', 'ABM', 'LS', 'WS']
                            .map((designation) => DropdownMenuItem(
                                  value: designation,
                                  child: Text(designation),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedDesignation = value;
                            _updateNames();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderDropdown(
                        name: 'name',
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _names
                            .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                ))
                            .toList(),
                        enabled: _names.isNotEmpty,
                        onChanged: (value) {
                          _saveData();
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _captureSelfie,
                        child: const Text('Capture Selfie'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_isImageCaptured ? 'Selfie Captured' : 'No image captured'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isImageCaptured ? _submitAttendance : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.yellow,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Mark Your Attendance'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
