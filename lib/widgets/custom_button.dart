import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed}); // ✅ Converted key to a super parameter & made constructor const

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ✅ Ensures button takes full width if required
      height: 50, // ✅ Sets a fixed height for uniformity
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16)), // ✅ Used const for Text
      ),
    );
  }
}
