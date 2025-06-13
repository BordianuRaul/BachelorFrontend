import 'package:flutter/material.dart';
import 'package:frontend/src/providers/journal_entry_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/blurred_background_journal_entry.dart';
import '../widgets/custom_text_field.dart';



class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<StatefulWidget> createState() => JournalEntryState();
}

class JournalEntryState extends State<JournalEntryScreen> {
  final FocusNode _beforeFocus = FocusNode();
  final FocusNode _timeFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();

  @override
  void dispose() {
    _beforeFocus.dispose();
    _timeFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

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
    return journalEntryProvider.beforeController.text.isNotEmpty &&
        journalEntryProvider.timeController.text.isNotEmpty &&
        journalEntryProvider.locationController.text.isNotEmpty;
  }

  Widget _buildTitleSection() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24), // add horizontal padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FittedBox(
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
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300), // limit max width for wrapping
                child: const Text(
                  'Answer the questions below to record your thoughts',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
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
                  customTextField(
                    'What did you do exactly before?',
                    Icons.history,
                    journalEntryProvider.beforeController,
                    _beforeFocus,
                  ),
                  const SizedBox(height: 15),
                  customTextField(
                    'What time of the day did it take place?',
                    Icons.access_time,
                    journalEntryProvider.timeController,
                    _timeFocus,
                  ),
                  const SizedBox(height: 15),
                  customTextField(
                    'Where were you when you did that?',
                    Icons.location_on,
                    journalEntryProvider.locationController,
                    _locationFocus,
                  ),
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

  Widget _buildSaveButton(JournalEntryProvider journalEntryProvider) {
    return ElevatedButton(
      onPressed: () {
        if (_isFormValid(journalEntryProvider)) {
          journalEntryProvider.saveEntry();
        } else {
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
