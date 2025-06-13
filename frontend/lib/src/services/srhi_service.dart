import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class SRHIService {
  final String? token = AuthService.token;

  static final SRHIService _instance = SRHIService._privateConstructor();

  SRHIService._privateConstructor();

  factory SRHIService() => _instance;

  //final String _baseUrl = 'http://10.0.2.2:8080/api/SRHI';
  final String _baseUrl = 'http://192.168.1.219:8080/api/SRHI'; // for physical devices


  Future<String> submitSRHI(List<int> answers) async {
    if (token == null) {
      throw Exception('Token not found. User might not be logged in.');
    }

    final url = Uri.parse('$_baseUrl/result');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(answers),
    );

    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Failed to submit SRHI form: ${response.body}');
    }
  }
}
