import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:km_tracker/widgets/loading_screen.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedBranch;
  String? _selectedPosition;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false); 

  void _addPerson() async {
    if (_formKey.currentState!.validate() &&
        _selectedBranch != null &&
        _selectedPosition != null) {
      _isLoading.value = true; 
      await FirebaseFirestore.instance.collection('employees').add({
        'name': _nameController.text,
        'designation': _selectedPosition,
        'branch': _selectedBranch,
      });
      _isLoading.value = false; 
      Navigator.pop(context);
    }
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
              title: const Text('Add Person'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        labelText: 'Full name',
                        enabledBorder: const OutlineInputBorder(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      hint: const Text('Select Position'),
                      items: [
                        'Sr. Manager',
                        'BM',
                        'ABM',
                        'LS',
                        'WS',
                      ].map((position) {
                        return DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a position';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        // labelText: 'Select Position',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      hint: const Text('Select Branch'),
                      items: [
                        'Manchar',
                        'Shirur',
                        'Nirgudsar',
                        'Urulikanchan',
                        'Sangamner',
                        'Alephata',
                      ].map((branch) {
                        return DropdownMenuItem(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBranch = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a branch';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        // labelText: 'Select Branch',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addPerson,
                      child: const Text('Add Person'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
