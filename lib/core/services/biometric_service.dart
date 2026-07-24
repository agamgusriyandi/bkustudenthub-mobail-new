import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _credentialIdKey = 'biometric_identifier';
  static const String _credentialPwdKey = 'biometric_password';

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Scan sidik jari Anda untuk melanjutkan',
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Preference
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  // Secure Storage for auto-login
  Future<void> saveCredentials(String identifier, String password) async {
    await _secureStorage.write(key: _credentialIdKey, value: identifier);
    await _secureStorage.write(key: _credentialPwdKey, value: password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final id = await _secureStorage.read(key: _credentialIdKey);
    final pwd = await _secureStorage.read(key: _credentialPwdKey);
    if (id != null && pwd != null) {
      return {'identifier': id, 'password': pwd};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _credentialIdKey);
    await _secureStorage.delete(key: _credentialPwdKey);
    await setBiometricEnabled(false);
  }
}
