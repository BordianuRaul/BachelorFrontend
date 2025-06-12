import 'package:flutter/material.dart';
import 'package:frontend/src/services/app_usage_service.dart';

class ExplorePossibleHabitsScreen extends StatefulWidget {
  const ExplorePossibleHabitsScreen({super.key});

  @override
  State<ExplorePossibleHabitsScreen> createState() => _ExplorePossibleHabitsScreenState();
}

class _ExplorePossibleHabitsScreenState extends State<ExplorePossibleHabitsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppUsage();
  }

  Future<void> _loadAppUsage() async {
    try {
      await AppUsageService().transferAppUsageInfo();
    } catch (e) {
      debugPrint("Error transferring app usage info: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? const _LoadingSection()
            : const Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150', // Replace with user photo
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, User!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Based on your usage, you might have these habits",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// CONTENT
            const Expanded(
              child: Center(
                child: Text(
                  'Possible habits will appear here soon.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
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
            "Possible habits are being identified...",
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
