import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_menu_provider.dart';
import '../widgets/add_journal_page_to_habit_card.dart';
import '../widgets/engrain_level_of_habit_card.dart';
import '../widgets/find_possible_habits_card.dart';
import '../widgets/possible_triggers_card.dart';

class HabitMenuScreen extends StatefulWidget {
  const HabitMenuScreen({super.key});

  @override
  _HabitMenuScreenState createState() => _HabitMenuScreenState();
}

class _HabitMenuScreenState extends State<HabitMenuScreen> with SingleTickerProviderStateMixin {
  double _dividerWidth = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _dividerWidth = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HabitMenuProvider>(
      create: (_) => HabitMenuProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Drawer(
          child: ListView(
            children: const [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.pinkAccent),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: const AssetImage('assets/images/rick.jpg'),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
              const SizedBox(height: 20),
              buildAddJournalPageToHabitCard(context),
              const SizedBox(height: 20),
              buildEngrainLevelOfHabitCard(context),
              const SizedBox(height: 20),
              buildPossibleTriggersCard(context),

            ],
          ),
        ),
      ),
    );
  }
}
