import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:usage_stats/usage_stats.dart';
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

    if (response.statusCode != 200) {
      throw Exception('Failed to send app usage data: ${response.statusCode} ${response.body}');
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
      List<ApplicationDailyUsage> dailyUsage = await _getApplicationsDailyUsageForDay(current);

      combinedUsage.addAll(dailyUsage);

      current = current.add(const Duration(days: 1));
    }

    return combinedUsage;
  }


  Future<List<ApplicationDailyUsage>> _getApplicationsDailyUsageForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    // Query usage stats
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(start, end);

    // Fetch installed apps once with icons and system apps
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(true, true);

    Map<String, ApplicationDailyUsage> appUsageMap = {};

    for (var info in usageStats) {
      final package = info.packageName;
      final totalTimeObj = info.totalTimeInForeground;
      final firstTimeStampObj = info.firstTimeStamp;
      final lastTimeUsedObj = info.lastTimeUsed;


      if (package == null || totalTimeObj == null || firstTimeStampObj == null || lastTimeUsedObj == null) {
        continue;
      }

      AppInfo? app = installedApps.firstWhereOrNull((a) => a.packageName == package);
      if (app == null) {
        continue;
      }

      final appName = app.name;
      final category = _getCategoryFromAppName(appName);

      final int? totalTime = int.tryParse(totalTimeObj);
      final int? firstTimeMillis = int.tryParse(firstTimeStampObj);
      final int? lastTimeMillis = int.tryParse(lastTimeUsedObj);

      if (totalTime == null || firstTimeMillis == null || lastTimeMillis == null) {
        continue;
      }

      final DateTime firstTimeStamp = DateTime.fromMillisecondsSinceEpoch(firstTimeMillis);
      final DateTime lastTimeUsed = DateTime.fromMillisecondsSinceEpoch(lastTimeMillis);

      final int estimatedHour = ((firstTimeStamp.hour + lastTimeUsed.hour) / 2).floor();

      final int totalTimeInSeconds = totalTime ~/ 1000;

      if (!appUsageMap.containsKey(package)) {
        appUsageMap[package] = ApplicationDailyUsage(
          name: appName,
          packageName: package,
          category: category,
          date: day,
          hourlyUsageInSeconds: List.filled(24, 0),
        );
      }

      appUsageMap[package]!.hourlyUsageInSeconds[estimatedHour] += totalTimeInSeconds;
    }

    return appUsageMap.values.toList();
  }

  //this can be refined by categorising in backend, but for now it's not so impactfull
  String _getCategoryFromAppName(String appName) {
    final name = appName.toLowerCase();
    if (name.contains('instagram')) return 'Social';
    if (name.contains('chrome')) return 'Browser';
    return 'Uncategorized';
  }


}
