import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:km_tracker/widgets/loading_screen.dart';

class DeletePersonPage extends StatefulWidget {
  const DeletePersonPage({super.key});

  @override
  _DeletePersonPageState createState() => _DeletePersonPageState();
}

class _DeletePersonPageState extends State<DeletePersonPage> {
  String? _selectedBranch;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);  // Loading state

  void _deletePerson(String documentId) async {
    _isLoading.value = true;
    await FirebaseFirestore.instance.collection('employees').doc(documentId).delete();
    _isLoading.value = false;
  }

  void _confirmDelete(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Do you really want to delete this person?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deletePerson(documentId);
                Navigator.of(context).pop(); 
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
              title: const Text('Delete Person'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                      border: OutlineInputBorder()
                    ),
                  ),
                  Expanded(
                    child: _selectedBranch == null
                        ? const Center(child: Text('Select a branch to see the people'))
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('employees')
                                .where('branch', isEqualTo: _selectedBranch)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final people = snapshot.data!.docs;
                              return ListView.builder(
                                itemCount: people.length,
                                itemBuilder: (context, index) {
                                  final person = people[index];
                                  return ListTile(
                                    title: Text(person['name']),
                                    subtitle: Text(person['designation']),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _confirmDelete(person.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
