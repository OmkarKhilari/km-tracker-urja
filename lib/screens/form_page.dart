import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:km_tracker/screens/login.dart';
import 'package:km_tracker/widgets/loading_screen.dart';

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
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
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
  File? _openingKmImage, _closingKmImage;
  final TextEditingController _openingKmController = TextEditingController();
  final TextEditingController _closingKmController = TextEditingController();
  final TextEditingController _differenceController = TextEditingController();
  double kmTravelled = 0;
  double openingKm = 0;
  double closingKm = 0;
  List<String>? _names;
  String? _selectedShift = 'Day';
  double _todaysAllowance = 0.0;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage(bool isOpeningKm) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (isOpeningKm) {
          _openingKmImage = File(image.path);
        } else {
          _closingKmImage = File(image.path);
        }
      });
    }
  }

  void submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      if (_openingKmImage == null || _closingKmImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please capture both images before submitting.')),
        );
        return;
      }

      _calculateTotalIncome();
      _isLoading.value = true;
      await _writeData();
      _isLoading.value = false;

      // Show an alert dialog with a "Done" button
      // ignore: use_build_context_synchronously
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Form Submitted'),
      //       content: const Text('Your form has been successfully submitted.'),
      //       actions: <Widget>[
      //         TextButton(
      //           child: const Text('Done'),
      //           onPressed: () {
      //             if (Platform.isAndroid || Platform.isIOS) {
      //               exit(0);
      //             }
      //             if (kIsWeb) {
      //               Navigator.of(context).pop();
      //             }
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (BuildContext context, bool isLoading, Widget? child) {
        return LoadingScreen(
          isLoading: isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("KM Tracker",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green.shade700,
              elevation: 0,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _formKey.currentState!.fields['position']!
                                  .reset();
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
                          _formKey.currentState!.fields['name']!
                              .didChange(null);
                          _updateNames();
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
                        decoration: InputDecoration(
                          labelText: 'Opening KM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _calculateDifference();
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _closingKmController,
                        decoration: InputDecoration(
                          labelText: 'Closing KM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _calculateDifference();
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _differenceController,
                        decoration: InputDecoration(
                          labelText: 'KM Travelled Today',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      FormBuilderDropdown(
                        name: 'shift',
                        decoration: InputDecoration(
                          labelText: 'Shift',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        initialValue: 'Day',
                        items: ['Day', 'Night', 'Sunday']
                            .map((shift) => DropdownMenuItem(
                                  value: shift,
                                  child: Text(shift),
                                ))
                            .toList(),
                        onChanged: (String? newShift) {
                          setState(() {
                            _selectedShift = newShift;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _captureImage(true),
                        child: const Text('Capture Opening KM Proof'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_openingKmImage != null ? 'Opening KM Proof Captured' : 'No image captured'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _captureImage(false),
                        child: const Text('Capture Closing KM Proof'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_closingKmImage != null ? 'Closing KM Proof Captured' : 'No image captured'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.yellow,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Submit'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Today\'s Allowance: ₹ ${_todaysAllowance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
    final allowance = _todaysAllowance;

    Map<String, dynamic> formData = {
      'branch': branch,
      'position': position,
      'name': name,
      'openingKm': openingKm,
      'closingKm': closingKm,
      'km_travelled_today': kmTravelled.toString(),
      'day': day,
      'is_sunday': isSunday.toString(),
      'daily_allowance': allowance,
    };

    try {
      String jsonData = jsonEncode(formData);
      String apiUrl = 'https://omkar.bhaskaraa45.me/write';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
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
        dailyAllowance += shift == 'Day'
            ? 100
            : shift == 'Sunday'
                ? 100
                : 60;
        break;
      default:
        break;
    }

    return dailyAllowance;
  }
}
