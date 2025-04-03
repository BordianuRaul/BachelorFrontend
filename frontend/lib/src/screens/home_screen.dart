import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/create_journal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  double _dividerWidth = 0.0;

  @override
  void initState() {
    super.initState();
    // Start animation when the page is loaded
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _dividerWidth = 1.0; // Expands to full width
      });
    });
  }

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
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
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
                  radius: 30, // Profile Picture Size
                  backgroundImage: const AssetImage('assets/images/rick.jpg'),
                  backgroundColor: Colors.grey[300],
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
                      userFirstName,
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
            const SizedBox(height: 20),
            buildJournalCard(context), // Existing journal card widget

            // New "Discovered a new habit?" vertical card with pale green tone
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Implement the action for the "Discovered a new habit?" card
                print("Discovered a new habit clicked");
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFA8D5BA), // Pale, bright green color
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline, // Icon representing discovery or a new idea
                      color: Colors.white,
                      size: 36, // Slightly bigger icon for vertical alignment
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Discovered a new habit?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
