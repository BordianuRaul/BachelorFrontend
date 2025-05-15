import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/src/providers/add_habit_provider.dart';
import '../widgets/blurred_background_journal_entry.dart'; // Or create a new one if needed

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<AddHabitProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          buildBlurredBackgroundJournalEntry(),
          _buildTitleSection(),
          _buildFormCard(habitProvider),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      left: 0,
      right: 0,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'New Habit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Create a habit to track consistently',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AddHabitProvider habitProvider) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    'Enter a habit name (e.g. Reading, Meditation)',
                    habitProvider.habitNameController,
                  ),
                  const SizedBox(height: 20),
                  _buildSaveButton(habitProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.black87),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildSaveButton(AddHabitProvider habitProvider) {
    return ElevatedButton(
      onPressed: () async {
        final success = await habitProvider.addHabit();
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit added successfully!')),
          );
          Navigator.pushNamed(context, '/home');
        } else if (habitProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(habitProvider.errorMessage!)),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6E947C),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      child: SizedBox(
        width: double.infinity,
        child: habitProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : const Text(
          'Add Habit',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
