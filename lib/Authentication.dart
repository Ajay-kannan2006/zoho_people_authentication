import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintAuthentication extends StatefulWidget {
  @override
  _FingerprintAuthenticationState createState() =>
      _FingerprintAuthenticationState();
}

class _FingerprintAuthenticationState extends State<FingerprintAuthentication> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _authStatus = 'Not Authenticated';

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authStatus = 'Authenticating...';
    });

    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      setState(() {
        _authStatus =
            didAuthenticate ? 'Authenticated' : 'Authentication Failed';
      });

      if (didAuthenticate) {
        // Proceed to the next screen or grant access
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NextScreen()),
        );
      }
    } catch (e) {
      print("Error during authentication: $e");
      setState(() {
        _authStatus = 'Authentication Error: $e';
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fingerprint Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _authenticate,
              child: _isAuthenticating
                  ? CircularProgressIndicator()
                  : Text('Authenticate'),
            ),
            SizedBox(height: 20),
            Text(
              _authStatus,
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Next Screen')),
      body: Center(child: Text('Welcome to the next screen!')),
    );
  }
}
