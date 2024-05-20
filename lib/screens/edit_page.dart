import 'package:flutter/material.dart';
import 'add_person_page.dart';
import 'delete_person_page.dart';

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPersonPage()),
                );
              },
              child: Text('Add People'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletePersonPage()),
                );
              },
              child: Text('Delete People'),
            ),
          ],
        ),
      ),
    );
  }
}
