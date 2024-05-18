import 'package:flutter/material.dart';

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Edit Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
