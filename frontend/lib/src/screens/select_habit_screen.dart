import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontend/src/models/habit.dart';
import 'package:frontend/src/providers/select_habit_provider.dart';
import 'package:frontend/src/screens/habit_menu_screen.dart';
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
        padding: const EdgeInsets.all(16.0),
        child: habits.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderSection(),
            const SizedBox(height: 24),
            Expanded(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(habits.length, (index) {
                  final habit = habits[index];
                  final color = getRandomColor();
                  final tileSize = getTileSizeForText(habit.getName());
                  final textColor = Colors.black87;

                  return StaggeredGridTile.count(
                    crossAxisCellCount: tileSize['w']!,
                    mainAxisCellCount: tileSize['h']!,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HabitMenuScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            habit.getName(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculates tile size based on text length
  Map<String, int> getTileSizeForText(String text) {
    final random = Random();
    int width;
    int height;

    if (text.length > 40) {
      width = 4;
      height = 2 + random.nextInt(2); // 2–3
    } else if (text.length > 20) {
      width = 3;
      height = 1 + random.nextInt(2); // 1–2
    } else {
      width = 2;
      height = 1 + random.nextInt(2); // 1–2
    }

    return {'w': width, 'h': height};
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

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> with SingleTickerProviderStateMixin {
  double _dividerWidth = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _dividerWidth = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/rick.jpg'), // change as needed
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ready to reflect?',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'pick a habit to journal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0, end: _dividerWidth),
            builder: (context, value, child) {
              return Container(
                height: 2.5,
                width: MediaQuery.of(context).size.width * value,
                color: Colors.black,
              );
            },
          ),
        ),
      ],
    );
  }
}
