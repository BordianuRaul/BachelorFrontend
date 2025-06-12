import 'package:flutter/material.dart';
import 'package:frontend/src/providers/add_habit_provider.dart';
import 'package:frontend/src/providers/auth_provider.dart';
import 'package:frontend/src/providers/explore_possible_habits_provider.dart';
import 'package:frontend/src/providers/habit_menu_provider.dart';
import 'package:frontend/src/providers/home_provider.dart';
import 'package:frontend/src/providers/journal_entry_provider.dart';
import 'package:frontend/src/providers/select_habit_provider.dart';
import 'package:frontend/src/providers/srhi_form_provider.dart';
import 'package:frontend/src/routes/routes.dart';
import 'package:frontend/src/screens/splash_screen.dart';
import 'package:frontend/src/screens/auth_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => JournalEntryProvider()),
        ChangeNotifierProvider(create: (_) => SelectHabitProvider()),
        ChangeNotifierProvider(create: (_) => AddHabitProvider()),
        ChangeNotifierProvider(create: (_) => HabitMenuProvider()),
        ChangeNotifierProvider(create: (_) => SRHIProvider()),
        ChangeNotifierProvider(create: (_) => ExplorePossibleHabitsProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      onGenerateRoute: Routes.generateRoute,
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}


