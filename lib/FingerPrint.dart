import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintEnrollment extends StatefulWidget {
  @override
  _FingerprintEnrollmentScreenState createState() =>
      _FingerprintEnrollmentScreenState();
}

class _FingerprintEnrollmentScreenState extends State<FingerprintEnrollment> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  String _enrollmentStatus = 'Not Enrolled';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  // Check if biometrics are available on the device
  Future<void> _checkBiometrics() async {
    bool canCheck = await _localAuth.canCheckBiometrics;
    setState(() {
      _canCheckBiometrics = canCheck;
    });
  }

  // Enroll the fingerprint
  Future<void> _enrollFingerprint() async {
    bool didAuthenticate = false;
    try {
      didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enroll fingerprint',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      setState(() {
        _enrollmentStatus = 'Enrollment Failed';
      });
    }

    if (didAuthenticate) {
      setState(() {
        _enrollmentStatus = 'Fingerprint Enrolled Successfully';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fingerprint Enrollment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_canCheckBiometrics)
              Text(
                'Your device does not support biometrics.',
                style: TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            if (_canCheckBiometrics)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _enrollFingerprint,
                    child: Text('Enroll Fingerprint'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _enrollmentStatus,
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
