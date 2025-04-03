
import 'dart:convert';

import 'package:frontend/src/services/auth_service.dart';

import '../models/habit.dart';
import '../models/journal.dart';
import 'package:http/http.dart' as http;

class JournalService {
  static Journal? journal;
  AuthService authService = AuthService();

  JournalService._privateConstructor();

  static final JournalService _instance = JournalService._privateConstructor();

  factory JournalService() {
    return _instance;
  }

  final String _baseUrl = 'http://10.0.2.2:8080/api/journal';
//final String _baseUrl = 'http://192.168.1.219:8080/api/journal'; // for physical devices



}