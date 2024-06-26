import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:km_tracker/database/upload_initial_data.dart';
import 'package:km_tracker/screens/form_page.dart';
import 'package:km_tracker/screens/login.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:km_tracker/services/firebase_options.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    //status bar color
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xff131921),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Uncomment the lines below to upload initial data to Firestore
  // print('started');
  // await uploadInitialData();
  // print('done');

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
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: LoginPage(),
    );
  }
}
