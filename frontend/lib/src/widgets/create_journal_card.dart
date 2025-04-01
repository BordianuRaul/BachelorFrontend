import 'package:flutter/material.dart';

Widget buildJournalCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Keeps spacing on sides
    child: InkWell(
      onTap: () {
        //TO DO: Add navigation to journal screen
      },
      splashColor: Colors.transparent,
      child: Card(
        color: const Color(0xffddedec), // Light greenish background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Increased vertical padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent excessive expansion
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories_outlined, size: 50, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded( // Makes text responsive to screen width
                    child: Text(
                      ' journal?',
                      style: TextStyle(
                        fontSize: 25, // Bigger text
                        fontFamily: 'Roboto', // Roboto font applied
                        fontWeight: FontWeight.bold, // Make it stand out
                      ),
                      overflow: TextOverflow.ellipsis, // Prevents overflow
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12), // Extra space below the row
              Text(
                '', // Additional text for better UX
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto', // Roboto applied
                  color: Colors.black54, // Softer text color
                ),
              ),
            ],
          ),
        ),
      ),
    )

  );
}
