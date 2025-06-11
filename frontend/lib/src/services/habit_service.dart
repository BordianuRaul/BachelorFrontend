
import '../models/user.dart';
import 'auth_service.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'auth_service.dart';

class HabitService {

  final String? token = AuthService.token;

  static final HabitService _instance = HabitService._privateConstructor();

  HabitService._privateConstructor();

  factory HabitService() => _instance;

  //final String _baseUrl = 'http://10.0.2.2:8080/api/users';
  final String _baseUrl = 'http://192.168.1.219:8080/api/users'; // for physical devices


  Future<void> addHabit(String name) async {
    if (token == null) {
      throw Exception('Token not found. User might not be logged in.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/addHabit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add habit: ${response.body}');
    }
  }
}
