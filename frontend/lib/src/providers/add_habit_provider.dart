import 'package:flutter/material.dart';
import 'package:frontend/src/services/habit_service.dart';

class AddHabitProvider extends ChangeNotifier {
  final TextEditingController habitNameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addHabit() async {
    final habitName = habitNameController.text.trim();
    if (habitName.isEmpty) {
      _errorMessage = "Habit name cannot be empty.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final habitService = HabitService();
      await habitService.addHabit(habitName);

      habitNameController.clear();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    habitNameController.dispose();
    super.dispose();
  }
}
