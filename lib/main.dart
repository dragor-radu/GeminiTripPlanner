import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
  late GenerativeModel geminiVisionProModel;
  late GenerativeModel geminiProModel;

  @override
  void initState() {
    geminiVisionProModel = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyBvQr96K6rinQ_31BqRD7fGIMdsZ1egUfg',
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting( HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ]
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Set LoginPage as the initial route
      initialRoute: '/google_maps',
      routes: {
        '/login': (context) => const LoginPage(),
        '/google_maps': (context) => const GoogleMapPage(),
      },
    );
  }
}
