
import 'package:flutter/material.dart';
import 'package:frontend/src/screens/journal_entry_screen.dart';

Widget habitCard(BuildContext context, {required String habit, required Color backgroundColor}) {
  // Determine whether the background color is light or dark
  final textColor = getTextColorForBackground(backgroundColor);

  return Card(
    elevation: 5,
    color: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JournalEntryScreen()),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: textColor, // Set icon color based on text visibility
              size: 30,
            ),
            const SizedBox(width: 16),
            Text(
              habit,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    ),
  );
}

Color getTextColorForBackground(Color color) {
  // Calculate brightness based on the luminance of the background color
  double luminance = color.computeLuminance();
  // If luminance is high (meaning the color is light), return dark text
  return luminance > 0.5 ? Colors.black : Colors.black;
}