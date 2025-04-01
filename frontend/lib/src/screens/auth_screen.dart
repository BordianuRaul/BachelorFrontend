import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/blurred_background.dart';
import '../widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          buildBlurredBackground(),
          _buildTitleSection(),
          _buildLoginRegisterCard(loginProvider),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.2,
      left: 0,
      right: 0,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Let\'s begin...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Login or Register to continue',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRegisterCard(AuthProvider loginProvider) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleSwitch(constraints),
                  const SizedBox(height: 20),
                  if (!isLogin) buildTextField('First Name', Icons.person, loginProvider.firstNameController, _firstNameFocusNode),
                  if (!isLogin) const SizedBox(height: 15),
                  if (!isLogin) buildTextField('Last Name', Icons.person, loginProvider.lastNameController, _lastNameFocusNode),
                  if (!isLogin) const SizedBox(height: 15),
                  buildTextField('Email Address', Icons.email, loginProvider.emailController, _emailFocusNode),
                  const SizedBox(height: 15),
                  buildTextField('Password', Icons.lock, loginProvider.passwordController, _passwordFocusNode, obscureText: true),
                  if (!isLogin) const SizedBox(height: 15),
                  if (!isLogin) buildTextField('Confirm Password', Icons.lock, loginProvider.confirmPasswordController, _confirmPasswordFocusNode, obscureText: true),
                  const SizedBox(height: 20),
                  _buildActionButton(loginProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(AuthProvider loginProvider) {
    return ElevatedButton(
      onPressed: () {
        if (isLogin) {
          loginProvider.login(context);
        } else {
          loginProvider.register(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6E947C),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          isLogin ? 'Login' : 'Register',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }


  Widget _buildToggleSwitch(BoxConstraints constraints) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = !isLogin),
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0F2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
              curve: Curves.easeInOut,
              child: Container(
                width: constraints.maxWidth * 0.5,
                height: 60,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: isLogin ? const Color(0xFF282828) : const Color(0xFFb8b8b8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: !isLogin ? const Color(0xFF282828) : const Color(0xFFb8b8b8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
