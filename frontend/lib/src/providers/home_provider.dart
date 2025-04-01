
import 'package:flutter/cupertino.dart';
import 'package:frontend/src/services/auth_service.dart';

class HomeProvider with ChangeNotifier {
  final AuthService authService = AuthService();

  String getUserFirstName() {
    return authService.getUserFirstName();
  }
}