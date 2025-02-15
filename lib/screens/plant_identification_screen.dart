import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlantIdentificationScreen extends StatefulWidget {
  const PlantIdentificationScreen({super.key});

  @override
  State<PlantIdentificationScreen> createState() => _PlantIdentificationScreenState();
}

class _PlantIdentificationScreenState extends State<PlantIdentificationScreen> {
  File? _selectedImage;
  String _resultText = "No plant identified yet.";

  /// ✅ **Pick an Image from Camera or Gallery**
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// ✅ **Placeholder Function for AI Processing**
  void _identifyPlant() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first!")),
      );
      return;
    }

    setState(() {
      _resultText = "🌱 AI is processing the image... (Coming soon)";
    });

    // TODO: Call AI Model here in the next steps
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Identification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📸 Display selected image
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : const Icon(Icons.image, size: 100, color: Colors.grey),

            const SizedBox(height: 10),

            // 📢 Display AI Result
            Text(_resultText, style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            // 🔘 Image Selection Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🚀 Identify Plant Button
            ElevatedButton(
              onPressed: _identifyPlant,
              child: const Text("Identify Plant"),
            ),
          ],
        ),
      ),
    );
  }
}
