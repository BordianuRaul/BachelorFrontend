import 'package:flutter/material.dart';
import 'package:frontend/src/providers/auth_provider.dart';
import 'package:frontend/src/providers/home_provider.dart';
import 'package:frontend/src/providers/journal_entry_provider.dart';
import 'package:frontend/src/providers/select_habit_provider.dart';
import 'package:frontend/src/routes/routes.dart';
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
      initialRoute: '/',
      onGenerateRoute: Routes.generateRoute,
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}
