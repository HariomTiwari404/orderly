import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obcureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obcureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obcureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color:
              Color.fromARGB(255, 255, 255, 255), // Change to a lighter color
          fontSize: 16, // Adjust font size as needed
          fontWeight: FontWeight.w400, // Adjust the weight as needed
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
