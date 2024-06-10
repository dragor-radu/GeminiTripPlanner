import 'package:flutter/material.dart';
import 'login.dart'; // Import your LoginPage
import 'google_maps.dart'; // Import your GoogleMapPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: prefer_typing_uninitialized_variables

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Set LoginPage as the initial route
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/google_maps': (context) => const GoogleMapPage(),
      },
    );
  }
}
