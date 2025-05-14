
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/habit.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {

  static User? user;
  static String? token;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      AuthService.user = User.fromJson(data['user']);
      AuthService.token = data['token'];

      await secureStorage.write(key: 'jwt_token', value: data['token']);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }
  }

  Future<List<Habit>> getHabitsForUser() async {
    if (AuthService.token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/getHabits'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> habitsData = jsonDecode(response.body);
      return habitsData.map((json) => Habit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load habits');
    }
  }

  Future<bool> validateToken() async {
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('$_baseUrl/validateToken'),
      headers: _authHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      user = User.fromJson(data['user']);
      return true;
    } else {
      await logout(); // Clean up expired token
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final storedToken = await secureStorage.read(key: 'jwt_token');
    if (storedToken == null) return false;

    token = storedToken;
    return await validateToken();
  }

  Future<void> logout() async {
    token = null;
    user = null;
    await secureStorage.delete(key: 'jwt_token');
  }

  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
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

}