import 'package:flutter/material.dart';

Widget buildFindPossibleHabitsCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Match journal & add habit card padding
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
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
