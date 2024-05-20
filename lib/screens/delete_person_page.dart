import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeletePersonPage extends StatefulWidget {
  @override
  _DeletePersonPageState createState() => _DeletePersonPageState();
}

class _DeletePersonPageState extends State<DeletePersonPage> {
  String? _selectedBranch;

  void _deletePerson(String documentId) {
    if (_selectedBranch != null) {
      FirebaseFirestore.instance
          .collection(_selectedBranch!)
          .doc(documentId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Person'),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _selectedBranch == null
                ? Center(child: Text('Select a branch to see the people'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(_selectedBranch!)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final people = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: people.length,
                        itemBuilder: (context, index) {
                          final person = people[index];
                          return ListTile(
                            title: Text(person['name']),
                            subtitle: Text(person['position']),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deletePerson(person.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
