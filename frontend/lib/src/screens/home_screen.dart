import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/add_habit_card.dart';
import '../widgets/create_journal_card.dart';
import '../widgets/find_possible_habits_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    String userFirstName = homeProvider.getUserFirstName();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _HeaderSection(userFirstName: userFirstName),
            const SizedBox(height: 20),
            buildJournalCard(context),
            const SizedBox(height: 20),
            buildAddHabitCard(context),
            const SizedBox(height: 20),
            buildFindPossibleHabitsCard(context),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatefulWidget {
  final String userFirstName;
  const _HeaderSection({required this.userFirstName});

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
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/rick.jpg'),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'morning,',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  widget.userFirstName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
