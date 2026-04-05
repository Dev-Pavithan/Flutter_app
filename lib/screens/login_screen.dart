import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:js_interop';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../app_theme.dart';
import '../mock_data.dart';
import 'dashboard_wrapper.dart';
import 'link_device_screen.dart';
import 'forgot_passcode_screen.dart';
import '../pwa_interop.dart';
import '../main.dart'; // Added for dashboardIndexNotifier support (needed by AppBar if we jump)

class LoginScreen extends StatefulWidget {
  final bool showInstallPrompt;

  const LoginScreen({super.key, this.showInstallPrompt = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _passcode = "";
  bool _isLoading = false;
  final String _correctPasscode = "1234";
  bool _isDeviceLinked = false;
  bool _biometricsEnabled = false;
  bool _hideInstallBanner = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceLink();
  }

  void _checkDeviceLink() async {
    final prefs = await SharedPreferences.getInstance();
    final linked = prefs.getBool('is_device_linked') ?? false;
    final bioEnabled = prefs.getBool('biometrics_enabled') ?? true;
    
    setState(() {
      _isDeviceLinked = linked;
      _biometricsEnabled = bioEnabled;
    });

    if (linked && bioEnabled) {
      // Auto-trigger biometric on start if enabled
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _handleBiometric();
      });
    }
  }

  void _handleKeyPress(String key) {
    if (_passcode.length < 4) {
      setState(() {
        _passcode += key;
      });
      if (_passcode.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void _handleDelete() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      });
    }
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('device_id');
    if (savedId != null) return savedId;

    String deviceId = 'unknown';
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'ios_${DateTime.now().millisecondsSinceEpoch}';
        } else {
          deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        }
      }
    } catch (e) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    await prefs.setString('device_id', deviceId);
    return deviceId;
  }

  void _verifyPasscode() async {
    setState(() => _isLoading = true);

    try {
      final deviceId = await _getDeviceId();
      
      const String apiUrl = 'https://urbanviewre.com/wstsc-backend/api/device-login';
      final url = Uri.parse(apiUrl);
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'passcode': _passcode,
          'device_name': kIsWeb ? 'Web Browser' : defaultTargetPlatform.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth_token', data['token'] ?? '');

        // Save user profile data from API response
        final userData = data['user'];
        if (userData != null) {
          final personData = userData['person'];
          final roleData = userData['role'];
          if (personData != null) {
            final firstName = personData['person_first_name'] ?? '';
            final lastName = personData['person_last_name'] ?? '';
            await prefs.setString('user_name', '$firstName $lastName'.trim());
            await prefs.setString('user_email', personData['person_email'] ?? '');
          }
          if (roleData != null) {
            await prefs.setString('user_role', roleData['role_name'] ?? 'teacher');
          }
        }
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const DashboardWrapper(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      } else if (response.statusCode == 404) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'DEVICE_NOT_FOUND') {
          setState(() {
            _isLoading = false;
            _passcode = "";
          });
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LinkDeviceScreen()),
            );
          }
        }
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Authentication failed';
        setState(() {
          _isLoading = false;
          _passcode = "";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppTheme.darkError, behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passcode = "";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: please check connection.'), backgroundColor: AppTheme.darkError, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _navigateToLink() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LinkDeviceScreen()),
    );
  }

  void _navigateToForgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasscodeScreen()),
    );
  }

  Future<void> _handleBiometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    
    // Check if biometric authentication is possible
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometric Check Error: $e');
    }

    if (!canCheck) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric security is not available or not set up on this device.'),
            backgroundColor: AppTheme.darkError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Trigger REAL system biometric prompt
    try {
      final bool didAuth = await auth.authenticate(
        localizedReason: 'Please authenticate to access your WSTSC account',
      );

      if (didAuth && mounted) {
        // SUCCESS: Use the cached pin or proceed with verified state
        final prefs = await SharedPreferences.getInstance();
        final cachedPin = prefs.getString('cached_passcode') ?? _correctPasscode;
        setState(() => _passcode = cachedPin);
        _verifyPasscode();
      }
    } catch (e) {
      debugPrint('Authentication Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: AppTheme.darkError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _triggerInstall() async {
    final result = await installPWA().toDart;
    if (result == true || result != null) {
      setState(() => _hideInstallBanner = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showBanner = widget.showInstallPrompt && !_hideInstallBanner;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.school, size: 48, color: AppTheme.darkAccent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Verify & Continue', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Enter your 4-digit security PIN', style: GoogleFonts.inter(color: Colors.white54)),
                const SizedBox(height: 48),
                
                // Passcode Dots
                _isLoading 
                  ? const CircularProgressIndicator(color: AppTheme.darkAccent)
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildDot(index < _passcode.length)),
                  ),
                
                const Spacer(flex: 3),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _navigateToForgot,
                      child: Text('Forgot PIN?', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.normal)),
                    ),
                    if (!_isDeviceLinked) ...[
                      const Text(' • ', style: TextStyle(color: Colors.white24)),
                      TextButton(
                        onPressed: _navigateToLink,
                        child: Text('Register New Device', style: GoogleFonts.inter(color: AppTheme.darkAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Keypad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    children: [
                      _buildKeypadRow(['1', '2', '3']),
                      _buildKeypadRow(['4', '5', '6']),
                      _buildKeypadRow(['7', '8', '9']),
                      _buildKeypadRow(['0', 'bio', 'del']),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // New Modal Themed Install UI
          if (showBanner)
            Positioned.fill(
              child: Container(
                color: Colors.black87.withOpacity(0.8),
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: AppTheme.darkAccent.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: AppTheme.darkAccent.withOpacity(0.1), blurRadius: 40, spreadRadius: 0),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.downloadCloud, color: AppTheme.darkAccent, size: 38),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Enhance Your Experience',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Install WSTSC on your home screen for quick access and biometric face login support.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _triggerInstall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkAccent,
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Install Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _hideInstallBanner = true),
                          child: Text('Maybe Later', style: GoogleFonts.inter(color: Colors.white38)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isFilled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isFilled ? AppTheme.darkAccent : Colors.white24,
        shape: BoxShape.circle,
        border: isFilled ? null : Border.all(color: Colors.white12),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    Widget child;
    if (key == 'bio') {
      child = const Icon(LucideIcons.fingerprint, color: AppTheme.darkAccent, size: 32);
    } else if (key == 'del') {
      child = const Icon(LucideIcons.delete, color: Colors.white54, size: 24);
    } else {
      child = Text(key, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
    }

    return InkWell(
      onTap: () {
        if (key == 'bio') {
          _handleBiometric();
        } else if (key == 'del') {
          _handleDelete();
        } else {
          _handleKeyPress(key);
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }

  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0C141C), Color(0xFF151F28), Color(0xFF0C141C)],
      ),
    ),
  );
}
