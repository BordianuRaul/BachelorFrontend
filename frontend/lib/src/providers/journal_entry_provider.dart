
import 'package:flutter/cupertino.dart';
import 'package:frontend/src/services/auth_service.dart';

class JournalEntryProvider extends ChangeNotifier {
  final AuthService authService = AuthService();
  final beforeController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();

  // Your save logic here
  void saveEntry() {
    // Logic to save the entry
  }

  @override
  void dispose() {
    beforeController.dispose();
    timeController.dispose();
    locationController.dispose();
    super.dispose();
  }
}