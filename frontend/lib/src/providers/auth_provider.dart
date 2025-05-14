import 'package:flutter/material.dart';
import 'package:frontend/src/services/permission_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final PermissionService _permissionService = PermissionService();

  bool isAuthenticated = false;
  bool isLoading = true;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final success = await _authService.tryAutoLogin();
    isAuthenticated = success;
    isLoading = false;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      await _authService.login(email, password);
      isAuthenticated = true;

      List<String> missingPermissions = await _permissionService.getMissingPermissions();

      if (missingPermissions.isEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/grantAccess');
      }

      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  Future<void> register(BuildContext context) async {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      if (!_authService.isPasswordValid(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, and one special character')),
        );
        return;
      }

      await _authService.register(firstName, lastName, email, password);
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
