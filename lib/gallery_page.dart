import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  final List<String> imageFiles = [
    'assets/images/ateneu.jpg',
    'assets/images/intercontinental.jpg',
    'assets/images/opera.jpg',
    'assets/images/opera_cluj.jpg',
    'assets/images/tulcea.jpg',
    'assets/images/arta.jpg',
  ];

  GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          crossAxisSpacing: 4.0, // Horizontal space between items
          mainAxisSpacing: 4.0, // Vertical space between items
        ),
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          return GridTile(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0), // Add radius here
              child: Image.asset(
                imageFiles[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}