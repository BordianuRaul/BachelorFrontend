import 'package:flutter/material.dart';
import 'package:frontend/src/screens/add_habit_screen.dart';
import 'package:frontend/src/screens/habit_menu_screen.dart';
import 'package:frontend/src/screens/journal_entry_screen.dart';
import 'package:frontend/src/screens/select_habit_screen.dart';
import 'package:frontend/src/screens/srhi_form_screen.dart';

import '../screens/splash_screen.dart';
import '../screens/grant_access_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/grantAccess':
        return MaterialPageRoute(builder: (_) => const GrantAccessScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/selectHabit':
        return MaterialPageRoute(builder: (_) => const SelectHabitScreen());
      case '/journalEntry':
        return MaterialPageRoute(builder: (_) => const JournalEntryScreen());
      case '/addHabit':
        return MaterialPageRoute(builder: (_) => const AddHabitScreen());
      case '/habitMenu':
        return MaterialPageRoute(builder: (_) => const HabitMenuScreen());
      case '/SRHIForm':
        return MaterialPageRoute(builder: (_) => const SRHIScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}