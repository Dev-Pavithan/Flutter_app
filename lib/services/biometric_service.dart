import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockEnabledKey = 'biometric_lock_enabled';

  static Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      print('Biometric Error: $e');
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access WSTSC',
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print('Authentication Error: $e');
      return false;
    }
  }

  static Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  static Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enabled);
  }
}
