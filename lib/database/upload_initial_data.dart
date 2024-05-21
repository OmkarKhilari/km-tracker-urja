import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:km_tracker/database/people_data.dart';

Future<void> uploadInitialData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // await _uploadData(firestore, 'Manchar', mancharData);
  // await _uploadData(firestore, 'Shirur', shirurData);
  // await _uploadData(firestore, 'Nirgudsar', nirgudsarData);
  // await _uploadData(firestore, 'Urulikanchan', urulikanchanData);
  // await _uploadData(firestore, 'Sangamner', sangamnerData);
  // await _uploadData(firestore, 'Alephata', alephataData);
}

Future<void> _uploadData(FirebaseFirestore firestore, String branch, List<List<String>> data) async {
  for (var entry in data) {
    await firestore.collection('employees').add({
      'id': entry[0],
      'name': entry[1],
      'designation': entry[2],
      'branch': branch,
    });
  }
}
