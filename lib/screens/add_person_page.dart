import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPersonPage extends StatefulWidget {
  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedBranch;

  void _addPerson() async {
    if (_formKey.currentState!.validate() && _selectedBranch != null) {
      await FirebaseFirestore.instance.collection(_selectedBranch!).add({
        'name': _nameController.text,
        'position': _positionController.text,
        'location': _locationController.text,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Person'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Position'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a position';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                hint: Text('Select Branch'),
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
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPerson,
                child: Text('Add Person'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
