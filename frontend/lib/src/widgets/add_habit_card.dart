import 'package:flutter/material.dart';

Widget buildAddHabitCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Match journal card padding
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/addHabit');
      },
      splashColor: Colors.transparent,
      child: Card(
        color: const Color(0xFFA8D5BA), // Pale green tone, same as before
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Match journal card padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent excessive expansion
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lightbulb_outline, size: 50, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'discovered a new habit?',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,  // Black text here
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
