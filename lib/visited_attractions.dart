import 'package:flutter/material.dart';

class VisitedAttractionsPage extends StatelessWidget {
  const VisitedAttractionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visited Attractions'),
      ),
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: Icon(Icons.location_pin), // Google Maps pin icon
            title: Text('The Great Pyramid of Giza'),
          ),
          ListTile(
            leading: Icon(Icons.location_pin),
            title: Text('The Colosseum in Rome'),
          ),
          ListTile(
            leading: Icon(Icons.location_pin),
            title: Text('The Statue of Liberty'),
          ),
          // Add more list items with random attraction names...
        ],
      ),
    );
  }
}