import 'package:flutter/material.dart';
import 'package:frontend/src/services/permission_service.dart';
import '../widgets/blurred_background_auth.dart';

//USE POPUPS INSTEAD OF BASIC BUTTONS

class GrantAccessScreen extends StatefulWidget {
  const GrantAccessScreen({super.key});

  @override
  GrantAccessScreenState createState() => GrantAccessScreenState();
}

class GrantAccessScreenState extends State<GrantAccessScreen> {
  final PermissionService _permissionService = PermissionService();
  List<String> missingPermissions = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final missing = await _permissionService.getMissingPermissions();
    setState(() {
      missingPermissions = missing;
    });
    if (missing.isEmpty) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, "/home");
  }

  Future<void> _grantLocationAccess() async {
    await _permissionService.requestLocationPermission();
    _checkPermissions();
  }

  Future<void> _grantUsageAccess() async {
    await _permissionService.requestUsageAccess();
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBlurredBackgroundAuth(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        _buildTextSection(),
        const Spacer(),
        _buildButtonSection(),
        const SizedBox(height: 40), // Extra space for bottom safe area
      ],
    );
  }

  Widget _buildTextSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(
            "Permissions Required",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
           SizedBox(height: 10),
           Text(
            "To continue, please grant the necessary permissions.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        children: [
          if (missingPermissions.contains("Location"))
            _buildPermissionButton("Allow Location", _grantLocationAccess),
          if (missingPermissions.contains("Usage Access"))
            _buildPermissionButton("Allow App Usage", _grantUsageAccess),
          const SizedBox(height: 20),
          _buildPermissionButton("Retry", _checkPermissions, isRetry: true),
        ],
      ),
    );
  }

  Widget _buildPermissionButton(String text, VoidCallback onPressed, {bool isRetry = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRetry ? const Color(0xFFD0E0F0) : const Color(0xFFF5F7FA), // Light blue for retry
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isRetry ? const BorderSide(color: Color(0xFFA0B0C0), width: 1.5) : BorderSide.none, // Subtle border for retry
          ),
          elevation: isRetry ? 2 : 3,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isRetry ? FontWeight.w600 : FontWeight.bold, // Retry is slightly lighter
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

}
