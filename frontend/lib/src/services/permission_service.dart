import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usage_stats/usage_stats.dart';

class PermissionService {
  PermissionService._privateConstructor();

  static final PermissionService _instance = PermissionService._privateConstructor();

  factory PermissionService() {
    return _instance;
  }

  Future<List<String>> getMissingPermissions() async {
    List<String> missingPermissions = [];

    if (!(await Permission.location.isGranted)) {
      missingPermissions.add('Location');
    }

    bool hasUsageAccess = await isUsageAccessGranted() ?? false;
    if (!hasUsageAccess) {
      missingPermissions.add('Usage Access');
    }

    return missingPermissions;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<void> openLocationSettings() async {
    await launchUrl(Uri.parse('android.settings.LOCATION_SOURCE_SETTINGS'));
  }

  Future<void> requestUsageAccess() async {
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  Future<bool?> isUsageAccessGranted() async {
    try {
      return await UsageStats.checkUsagePermission() ?? false;
    } catch (e) {
      return false;
    }
  }
}
