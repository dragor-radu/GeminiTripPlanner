import 'package:flutter/material.dart';

class FuturePlansPage extends StatelessWidget {
  final List<String> destinations = [
    'Paris, France',
    'Tokyo, Japan',
    'New York, USA',
    // Add more destinations as needed
  ];

  FuturePlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Plans'),
      ),
      body: ListView.builder(
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.flight_takeoff), // Icon for visual appeal
            title: Text(destinations[index]),
          );
        },
      ),
    );
  }
}