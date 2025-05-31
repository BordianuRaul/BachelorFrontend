import 'package:flutter/material.dart';

class SRHIProvider extends ChangeNotifier {
  final int questionCount = 12;
  final List<int?> answers = List<int?>.filled(12, null); // Nullable so we can check validation

  void setAnswer(int index, int value) {
    answers[index] = value;
    notifyListeners();
  }

  bool isFormValid() {
    return !answers.contains(null);
  }

  List<int> getFinalAnswers() {
    return answers.map((e) => e ?? 0).toList(); // Defensive fallback
  }
}
