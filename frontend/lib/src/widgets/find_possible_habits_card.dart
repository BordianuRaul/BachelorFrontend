import 'package:flutter/material.dart';

Widget buildFindPossibleHabitsCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: InkWell(
      onTap: () async {
        Navigator.pushNamed(context, '/exploreHabits');
      },
      splashColor: Colors.transparent,
      child: Card(
        color: const Color(0xFFF8C8DC), // Pale pink tone
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align icon and text at the top
                children: [
                  Icon(Icons.travel_explore, size: 50, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'explore possible habits',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible, // Allow full wrap
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                '', // Optional subtitle
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
