import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/srhi_form_provider.dart';
import '../services/srhi_service.dart';
import '../widgets/srhi_result_dialog.dart';

class SRHIScreen extends StatefulWidget {
  const SRHIScreen({super.key});

  @override
  State<SRHIScreen> createState() => _SRHIScreenState();
}

class _SRHIScreenState extends State<SRHIScreen> with SingleTickerProviderStateMixin {
  double _dividerWidth = 0.0;

  final List<String> questions = const [
    'I engage in this behavior frequently.',
    'I perform this behavior automatically.',
    'I engage in this behavior without consciously remembering.',
    'I feel uncomfortable if I do not perform this behavior.',
    'I perform this behavior without deliberate thought.',
    'Avoiding this behavior requires effort.',
    'This behavior is an integral part of my routine.',
    'I begin this behavior before I realize I am doing it.',
    'I find it difficult not to engage in this behavior.',
    'I do not need to think about performing this behavior.',
    'This behavior is characteristic of me.',
    'I have engaged in this behavior for a long time.',
  ];

  final List<Color> scaleColors = const [
    Color(0xFFD32F2F),
    Color(0xFFF57C00),
    Color(0xFFFFEB3B),
    Color(0xFFBDBDBD),
    Color(0xFF9CCC65),
    Color(0xFF66BB6A),
    Color(0xFF388E3C),
  ];

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
    final provider = Provider.of<SRHIProvider>(context);

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
            // Top user avatar + message
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: const AssetImage('assets/images/rick.jpg'), // Replace as needed
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'please reflect honestly',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'complete the SRHI form',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Divider animation
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

            const SizedBox(height: 25),

            const Text(
              'Please complete the form below. Select how much you agree with each statement using the scale from Strongly Disagree (Red) to Strongly Agree (Green).',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),


            const SizedBox(height: 15),

            // Questions list
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(index, questions[index], provider);
                },
              ),
            ),

            const SizedBox(height: 10),

            // Submit button
            ElevatedButton(
              onPressed: () async {
                if (provider.isFormValid()) {
                  try {
                    final resultMessage = await SRHIService().submitSRHI(provider.getFinalAnswers());

                    await showDialog(
                      context: context,
                      builder: (ctx) => SRHIResultDialog(
                        resultMessage: resultMessage,
                        onOk: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Submission failed: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please answer all questions")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E947C),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Center(
                child: Text(
                  'Submit SRHI Form',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, String question, SRHIProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final value = i + 1;
              final isSelected = provider.answers[index] == value;

              return GestureDetector(
                onTap: () => provider.setAnswer(index, value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? scaleColors[i] : scaleColors[i].withOpacity(0.3),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: isSelected
                      ? const Center(
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),
              );

            }),
          ),
        ],
      ),
    );
  }
}
