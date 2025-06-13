
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/src/services/app_usage_service.dart';

import '../widgets/habit_confirmation_dialog.dart';
import 'add_habit_screen.dart';

class ExplorePossibleTriggersScreen extends StatefulWidget {
  const ExplorePossibleTriggersScreen({super.key});

  @override
  State<ExplorePossibleTriggersScreen> createState() => _ExplorePossibleTriggersScreenState();
}

class _ExplorePossibleTriggersScreenState extends State<ExplorePossibleTriggersScreen> {
  bool _isLoading = true;
  List<String> _possibleHabits = [];

  final List<Color> _colorPalette = [
    const Color(0xFFB4E197),
    const Color(0xFF99C4C8),
    const Color(0xFFFFD3B6),
    const Color(0xFFE5A9A9),
    const Color(0xFFA8D5BA),
    const Color(0xFFADC9E6),
    const Color(0xFFC3B1E1),
    const Color(0xFFFFABAB),
    const Color(0xFFFFD6E0),
    const Color(0xFFFFF5C3),
  ];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadPossibleHabits();
  }

  Future<void> _loadPossibleHabits() async {
    try {
      await AppUsageService().transferAppUsageInfo();
      final habits = await AppUsageService().fetchPossibleHabits();
      if (mounted) {
        setState(() {
          _possibleHabits = habits;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, int> _getTileSizeForMessage(String message) {
    if (message.length > 100) return {'w': 4, 'h': 2};
    if (message.length > 50) return {'w': 3, 'h': 2};
    return {'w': 4, 'h': 1};
  }

  Color _getRandomColor() {
    return _colorPalette[_random.nextInt(_colorPalette.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Habits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const _LoadingSection()
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderSection(),
            const SizedBox(height: 24),
            _possibleHabits.isEmpty
                ? const Center(child: Text('No triggers found.'))
                : Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _possibleHabits.map((habit) {
                    final tileSize = _getTileSizeForMessage(habit);
                    final color = _getRandomColor();

                    final width = 100.0 * tileSize['w']!;
                    final height = 80.0 * tileSize['h']!;

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => HabitConfirmationDialog(
                            habitText: habit,
                            onConfirm: () {
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen()));
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Text(
                            habit,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );

                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            "Possible triggers for habits are being identified...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
              backgroundImage: AssetImage('assets/images/rick.jpg'), // You can customize this
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ready to explore?',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'your habit journey',
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
