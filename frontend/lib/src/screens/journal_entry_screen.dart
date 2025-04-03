import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/src/providers/journal_entry_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/blurred_background_auth.dart';
import '../widgets/blurred_background_journal_entry.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<StatefulWidget> createState() => JournalEntryState();
}

class JournalEntryState extends State<JournalEntryScreen> {
  @override
  Widget build(BuildContext context) {
    final journalEntryProvider = Provider.of<JournalEntryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          buildBlurredBackgroundJournalEntry(),
          _buildTitleSection(),
          _buildFormCard(journalEntryProvider),
        ],
      ),
    );
  }

  bool _isFormValid(JournalEntryProvider journalEntryProvider) {
    // Basic validation: check if all fields are filled
    return journalEntryProvider.beforeController.text.isNotEmpty &&
        journalEntryProvider.timeController.text.isNotEmpty &&
        journalEntryProvider.locationController.text.isNotEmpty;
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
              'Journal Entry',
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
              'Answer the questions below to record your thoughts',
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

  Widget _buildFormCard(JournalEntryProvider journalEntryProvider) {
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
                  _buildTextField('What did you do exactly before?', journalEntryProvider.beforeController),
                  const SizedBox(height: 15),
                  _buildTextField('What time of the day did it take place?', journalEntryProvider.timeController),
                  const SizedBox(height: 15),
                  _buildTextField('Where were you when you did that?', journalEntryProvider.locationController),
                  const SizedBox(height: 20),
                  _buildSaveButton(journalEntryProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String question, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: question,
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

  Widget _buildSaveButton(JournalEntryProvider journalEntryProvider) {
    return ElevatedButton(
      onPressed: () {
        if (_isFormValid(journalEntryProvider)) {
          // Save entry logic here
          journalEntryProvider.saveEntry();
        } else {
          // Show validation message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill out all fields')),
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
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          'Save Entry',
          textAlign: TextAlign.center,
          style: const TextStyle(
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
