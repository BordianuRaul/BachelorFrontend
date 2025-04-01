
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildTextField(String label, IconData icon, TextEditingController controller, FocusNode focusNode, {bool obscureText = false}) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    obscureText: obscureText,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFb8b8b8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5F5F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5F5F5)),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF6E947C), size: 32),
      ),
    ),
    style: const TextStyle(color: Colors.black),
  );
}