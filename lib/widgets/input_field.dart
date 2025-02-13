import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const InputField({super.key, required this.label, required this.controller, this.obscureText = false}); // ✅ Converted key to a super parameter & made constructor const

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // ✅ Ensures consistent input field height
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // ✅ Used const
          border: OutlineInputBorder( // ✅ Added border for better UI
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.green, width: 2.0), // ✅ Green border when focused
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
      ),
    );
  }
}
