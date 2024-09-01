import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final String adminEmail = "ajay@gmail.com";
  final String adminPassword = "123";

  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;
  String _status = 'Not Enrolled';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      final bool isEnrolled = availableBiometrics.isNotEmpty;

      setState(() {
        _canCheckBiometrics = canCheck && isEnrolled;
      });
    } catch (e) {
      print("Error checking biometrics: $e");
      setState(() {
        _canCheckBiometrics = false;
      });
    }
  }

  Future<void> _authenticate() async {
    if (!_canCheckBiometrics) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometrics not available or not enrolled')),
      );
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _status = 'Authenticated Successfully';
          // Proceed to enrollment or other features
        });
      } else {
        setState(() {
          _status = 'Authentication Failed';
        });
      }
    } catch (e) {
      print("Error during authentication: $e");
      setState(() {
        _status = 'Authentication Failed';
      });
    }

    setState(() {
      _isAuthenticating = false;
    });
  }

  void _login() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email == adminEmail && password == adminPassword) {
      // Proceed to biometric authentication
      _authenticate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _login,
              child: _isAuthenticating
                  ? CircularProgressIndicator()
                  : Text('Login and Authenticate'),
            ),
            SizedBox(height: 20),
            Text(
              _status,
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
