import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:km_tracker/screens/form_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    //status bar color
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xff131921),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'KM Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green, 
          accentColor: Colors.red, 
        ).copyWith(
          background: Colors.white, 
        ),
      ),
      home: FormPage(),
    );
  }
}
