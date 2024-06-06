import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<EmployeeData> _employeeData = [];
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchEmployeeData() async {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KM Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
        employeeData: _employeeData,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<EmployeeData> employeeData;

  const HomePage({Key? key, required this.employeeData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  PlatformFile? _openingKmFile, _closingKmFile;
  final TextEditingController _openingKmController = TextEditingController();
  final TextEditingController _closingKmController = TextEditingController();
  final TextEditingController _differenceController = TextEditingController();
  double kmTravelled = 0;
  double openingKm = 0;
  double closingKm = 0;
  List<String>? _names;
  String? _selectedShift = 'Day';
  double _todaysAllowance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KM Tracker"),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              FormBuilderDropdown(
                name: 'branch',
                decoration: InputDecoration(
                  labelText: 'Select Branch',
                  hintText: 'Select Branch',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _formKey.currentState!.fields['branch']!.reset();
                      setState(() {
                        _names = null;
                      });
                    },
                  ),
                ),
                items: [
                  'Manchar',
                  'Alephata',
                  'Urulikanchan',
                  'Shirur',
                  'Sangamner',
                  'Nirgudsar'
                ]
                    .map((branch) => DropdownMenuItem(
                          value: branch,
                          child: Text(branch),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              FormBuilderDropdown(
                name: 'position',
                decoration: InputDecoration(
                  labelText: 'Select Position',
                  hintText: 'Select Position',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _formKey.currentState!.fields['position']!.reset();
                      setState(() {
                        _names = null;
                      });
                    },
                  ),
                ),
                items: ['Sr. Manager', 'BM', 'ABM', 'LS', 'WS']
                    .map((position) => DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        ))
                    .toList(),
                onChanged: (String? newPosition) {
                  _formKey.currentState!.fields['name']!.didChange(null);
                  _updateNames();
                },
              ),
              const SizedBox(height: 20),
              FormBuilderDropdown(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                items: _names
                        ?.map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList() ??
                    [],
                enabled: _names != null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _openingKmController,
                decoration: const InputDecoration(
                  labelText: 'Opening KM',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateDifference();
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _closingKmController,
                decoration: const InputDecoration(
                  labelText: 'Closing KM',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateDifference();
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _differenceController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'KM Travelled Today',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedShift,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedShift = newValue;
                  });
                },
                items: ['Day', 'Night']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _openingKmFile = result.files.first;
                    });
                  }
                },
                child: const Text('Opening KM PROOF (Select File)'),
              ),
              const SizedBox(height: 10),
              Text(_openingKmFile?.name ?? 'No file selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _closingKmFile = result.files.first;
                    });
                  }
                },
                child: const Text('Closing KM PROOF (Select File)'),
              ),
              const SizedBox(height: 10),
              Text(_closingKmFile?.name ?? 'No file selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    _writeData();
                    _calculateTotalIncome();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.yellow,
                ),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              Text(
                'Today\'s Allowance: ₹ ${_todaysAllowance.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculateDifference() {
    openingKm = double.tryParse(_openingKmController.text) ?? 0.0;
    closingKm = double.tryParse(_closingKmController.text) ?? 0.0;
    final difference = closingKm - openingKm;
    setState(() {
      kmTravelled = difference;
      _differenceController.text = difference.toString();
    });
  }

  void _updateNames() {
    final branch = _formKey.currentState?.fields['branch']?.value;
    final position = _formKey.currentState?.fields['position']?.value;
    if (branch != null && position != null) {
      setState(() {
        _names = widget.employeeData
            .where(
                (data) => data.branch == branch && data.designation == position)
            .map((data) => data.name)
            .toList();
      });
    }
  }

  Future<void> _writeData() async {
    final branch = _formKey.currentState?.fields['branch']?.value;
    final position = _formKey.currentState?.fields['position']?.value;
    final name = _formKey.currentState?.fields['name']?.value;
    final day = DateTime.now().toIso8601String();
    final isSunday = DateTime.now().weekday == DateTime.sunday;

    Map<String, dynamic> formData = {
      'branch': branch,
      'position': position,
      'name': name,
      'openingKm' : openingKm,
      'closingKm' : closingKm,
      'km_travelled_today': kmTravelled.toString(),
      'day': day,
      'is_sunday': isSunday.toString(),
    };

    try {
      String jsonData = jsonEncode(formData);
      String apiUrl = 'http://127.0.0.1:8000/write/';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data written successfully');
        // Show a success message to the user
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data written successfully')),
        );
      } else {
        print('Failed to write data: ${response.body}');
        // Show an error message to the user
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to write data: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error occurred while writing data: $e');
      // Show an error message to the user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while writing data: $e')),
      );
    }
  }

  void _calculateTotalIncome() {
    final name = _formKey.currentState?.fields['name']?.value;
    final position = _formKey.currentState?.fields['position']?.value;
    final shift = _selectedShift ?? 'Day';
    final isSunday = DateTime.now().weekday == DateTime.sunday;

    if (name != null && position != null) {
      final employee = widget.employeeData.firstWhere(
          (data) => data.name == name && data.designation == position);
      final dailyAllowance =
          employee.calculateDailyAllowance(shift, isSunday, kmTravelled);
      setState(() {
        _todaysAllowance = dailyAllowance;
      });
      print('Total income for $name: ₹ ${dailyAllowance.toStringAsFixed(2)}');
    }
  }
}

class EmployeeData {
  final String name;
  final String designation;
  final String branch;

  EmployeeData({
    required this.name,
    required this.designation,
    required this.branch,
  });

  double calculateDailyAllowance(
      String shift, bool isSunday, double kmTravelled) {
    double dailyAllowance = 3.2 * kmTravelled;

    switch (designation) {
      case 'BM':
        dailyAllowance += shift == 'Day' ? 90 : 120;
        break;
      case 'ABM':
        dailyAllowance += shift == 'Day' ? 75 : 120;
        break;
      case 'LS':
        dailyAllowance += shift == 'Day' ? 60 : 120;
        break;
      case 'WS':
        dailyAllowance += shift == 'Day' ? 100 : 60;
        if (isSunday) dailyAllowance += 100;
        break;
      default:
        break;
    }

    return dailyAllowance;
  }
}
