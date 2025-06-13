import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:frontend/src/models/application_daily_usage.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

class AppUsageService {
  final String? token = AuthService.token;

  static final AppUsageService _instance = AppUsageService._privateConstructor();
  AppUsageService._privateConstructor();

  factory AppUsageService() {
    return _instance;
  }

  //final String _baseUrl = 'http://10.0.2.2:8080/api/appUsage';
  final String _baseUrl = 'http://192.168.1.219:8080/api/appUsage'; // for physical devices

  Future<void> transferAppUsageInfo() async {
    if (token == null) {
      throw Exception('Token not found. User might not be logged in.');
    }

    DateTime lastUpdateDate = await _getDateOfTheLastUpdate();
    List<ApplicationDailyUsage> appsUsageInfo = await _getApplicationsDailyUsageFromInterval(
      lastUpdateDate,
      DateTime.now(),
    );

    String jsonPayload = _buildAppsUsageForJson(appsUsageInfo);

    final url = Uri.parse('$_baseUrl/bulk');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonPayload,
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('Failed to send app usage data: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<String>> fetchPossibleHabits() async {
    if (token == null) {
      throw Exception('Token not found. User might not be logged in.');
    }

    final url = Uri.parse('$_baseUrl/findPossibleHabits');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to fetch possible habits: ${response.statusCode} ${response.body}');
    }
  }

  Future<DateTime> _getDateOfTheLastUpdate() async {
    if (token == null) {
      throw Exception('Token not found. User might not be logged in.');
    }

    final url = Uri.parse('$_baseUrl/lastUpdate');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String rawDate = response.body.trim();
      return DateTime.parse(rawDate);
    } else {
      throw Exception('Failed to get last update date: ${response.statusCode}');
    }
  }

  String _buildAppsUsageForJson(List<ApplicationDailyUsage> appsUsage) {
    List<Map<String, dynamic>> jsonList = appsUsage.map((app) => app.toJson()).toList();
    return jsonEncode(jsonList);
  }

  Future<List<ApplicationDailyUsage>> _getApplicationsDailyUsageFromInterval(DateTime start, DateTime end) async {
    List<ApplicationDailyUsage> combinedUsage = [];

    DateTime current = DateTime(start.year, start.month, start.day);
    DateTime finalDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(finalDate)) {
      // Compute start and end millis for this day (full day range)
      final dayStart = current;
      final dayEnd = current.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      List<ApplicationDailyUsage> dailyUsage = await _getApplicationsDailyUsageForDay(dayStart, dayEnd);

      combinedUsage.addAll(dailyUsage);

      current = current.add(const Duration(days: 1));
    }

    return combinedUsage;
  }

  Future<List<ApplicationDailyUsage>> _getApplicationsDailyUsageForDay(
      DateTime start, DateTime end) async {
    const platform = MethodChannel('app_usage_channel');

    // Call the native Android method
    final Map<String, dynamic> nativeUsageMap = Map<String, dynamic>.from(
      await platform.invokeMethod('getHourlyAppUsage', {
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      }),
    );

    // Get list of installed apps to resolve package names
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(true, true);

    List<ApplicationDailyUsage> results = [];

    // Iterate through each app's usage data
    for (final appEntry in nativeUsageMap.entries) {
      final packageName = appEntry.key;
      final dayUsageMap = Map<String, dynamic>.from(appEntry.value);

      final app = installedApps.firstWhereOrNull(
            (a) => a.packageName == packageName,
      );
      if (app == null) continue;

      final category = _getCategoryFromAppName(app.name);

      // Each day in the date range
      for (final dayEntry in dayUsageMap.entries) {
        final dateStr = dayEntry.key;
        final usageList = List<int>.from(dayEntry.value); // Should contain 24 elements

        // Parse the date from "yyyy-MM-dd"
        final dateParts = dateStr.split("-");
        if (dateParts.length != 3) continue; // Skip malformed entries

        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );

        results.add(ApplicationDailyUsage(
          name: app.name,
          packageName: packageName,
          category: category,
          date: date,
          hourlyUsageInSeconds: usageList,
        ));
      }
    }

    return results;
  }

  //this can be refined by categorising in backend, but for now it's not so impactfull
  String _getCategoryFromAppName(String appName) {
    final name = appName.toLowerCase();
    if (name.contains('instagram')) return 'Social';
    if (name.contains('chrome')) return 'Browser';
    return 'Uncategorized';
  }


}
