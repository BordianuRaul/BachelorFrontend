
import 'package:flutter/cupertino.dart';

import '../services/auth_service.dart';

class SelectHabitProvider with ChangeNotifier {
  final AuthService authService = AuthService();
}