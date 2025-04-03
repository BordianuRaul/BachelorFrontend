import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontend/src/models/habit.dart';
import 'package:frontend/src/providers/select_habit_provider.dart';
import 'package:frontend/src/screens/journal_entry_screen.dart';
import 'package:provider/provider.dart';

class SelectHabitScreen extends StatefulWidget {
  const SelectHabitScreen({super.key});

  @override
  State<StatefulWidget> createState() => SelectHabitState();
}

class SelectHabitState extends State<SelectHabitScreen> {
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  void _fetchHabits() async {
    final authProvider = Provider.of<SelectHabitProvider>(context, listen: false);
    try {
      habits = await authProvider.authService.getHabitsForUser();
      setState(() {});
    } catch (e) {
      print("Error fetching habits: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: habits.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: List.generate(habits.length, (index) {
            final habit = habits[index];
            final color = getRandomColor();
            final tileSize = getRandomTileSize();
            final textColor = Colors.black54;

            return StaggeredGridTile.count(
              crossAxisCellCount: tileSize['w']!,
              mainAxisCellCount: tileSize['h']!,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JournalEntryScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        habit.getName(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Gives a random tile size from a few Metro-style options
  Map<String, int> getRandomTileSize() {
    List<Map<String, int>> sizes = [
      {'w': 2, 'h': 2}, // Square
      {'w': 2, 'h': 1}, // Wide
      {'w': 1, 'h': 2}, // Tall
      {'w': 1, 'h': 1}, // Small
    ];
    return sizes[Random().nextInt(sizes.length)];
  }

  Color getRandomColor() {
    List<Color> colors = [
      const Color(0xFFB4E197), const Color(0xFF99C4C8), const Color(0xFFFFD3B6),
      const Color(0xFFE5A9A9), const Color(0xFFA8D5BA), const Color(0xFFADC9E6),
      const Color(0xFFC3B1E1), const Color(0xFFFFABAB), const Color(0xFFFFD6E0),
      const Color(0xFFFFF5C3), const Color(0xFFC1E1C1), const Color(0xFFAED9E0),
      const Color(0xFFF4C2C2), const Color(0xFFEEA29A), const Color(0xFFDBB8D0),
      const Color(0xFFFFB6C1), const Color(0xFFFAE3D9), const Color(0xFF9AD2CB),
      const Color(0xFFD6A2E8), const Color(0xFFAEC6CF), const Color(0xFFFADADD),
      const Color(0xFFFFC3A0), const Color(0xFFF8E1F4), const Color(0xFFCCD5AE),
      const Color(0xFFABC4A3), const Color(0xFFE0BBE4), const Color(0xFFC5E1A5),
      const Color(0xFFF5CBA7), const Color(0xFFDAE2B6), const Color(0xFFB6D7A8),
      const Color(0xFFD4A5A5), const Color(0xFFB5E7E7), const Color(0xFFBDE0FE),
      const Color(0xFFE8A87C), const Color(0xFFFFD166), const Color(0xFFA8E6CF),
      const Color(0xFFDCEDC1), const Color(0xFFB5A1E5), const Color(0xFFB39DDB),
      const Color(0xFFE6B89C), const Color(0xFF9DB4C0), const Color(0xFFD6C6E1),
      const Color(0xFFFFC5C5), const Color(0xFFD1E8E4), const Color(0xFFC3E88D),
      const Color(0xFFA3C4BC), const Color(0xFFF4D06F), const Color(0xFFAAC8A7),
      const Color(0xFFD9BF77), const Color(0xFF9CBBAD)
    ];
    return colors[Random().nextInt(colors.length)];
  }

}
