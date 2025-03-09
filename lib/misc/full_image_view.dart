import 'package:flutter/material.dart';

class FullImageView extends StatelessWidget {
  final String imageUrl;
  final String title; // Full name or mobile number

  const FullImageView({Key? key, required this.imageUrl, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background like WhatsApp
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title, // Display full name or mobile number
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 3.0, // Allow zooming
          child: AspectRatio(
            aspectRatio: 1, // Square image display
            child: (imageUrl.isNotEmpty)
                ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _noProfilePhoto(),
            )
                : _noProfilePhoto(), // Show text if imageUrl is empty
          ),
        ),
      ),
    );
  }

  Widget _noProfilePhoto() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        "No Profile Photo",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
