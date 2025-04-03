
import 'dart:convert';

import '../models/habit.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {

  static User? user;

  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();

  factory AuthService() {
    return _instance;
  }

  final String _baseUrl = 'http://10.0.2.2:8080/api/users';
  //final String _baseUrl = 'http://192.168.1.219:8080/api/users'; // for physical devices

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      AuthService.user = User.fromJson(data['user']);

    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final String responseString = response.body;
    } else {
      throw Exception('Failed to register');
    }
  }

  bool isPasswordValid(String password) {
    return password.length >= 8 && password.contains(RegExp(r'[0-9]')) && password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  String getUserFirstName() {
    return AuthService.user!.firstName;
  }

  String getUserId() {
    return AuthService.user!.id;
  }

  Future<List<Habit>> getHabitsForUser() async {
    if (AuthService.user == null) {
      throw Exception('User is not logged in');
    }

    final userId = AuthService.user!.id;
    final url = Uri.parse('$_baseUrl/getHabits?userId=$userId');

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response into Habit objects
      final List<dynamic> habitsData = jsonDecode(response.body);
      List<Habit> habits = habitsData.map((habitJson) => Habit.fromJson(habitJson)).toList();
      return habits;
    } else {
      throw Exception('Failed to load habits');
    }
  }
}