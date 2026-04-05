import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../app_theme.dart';
import 'dashboard_wrapper.dart';

class LinkDeviceScreen extends StatefulWidget {
  const LinkDeviceScreen({super.key});

  @override
  State<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

class _LinkDeviceScreenState extends State<LinkDeviceScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  int _step = 1; // 1: Email/Password, 2: Set PIN

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

  void _handleLink() async {
    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 4 digits'), backgroundColor: AppTheme.darkError),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deviceId = await _getDeviceId();
      const String apiUrl = 'https://urbanviewre.com/wstsc-backend/api/link-device';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'device_id': deviceId,
          'device_name': kIsWeb ? 'Web Browser' : defaultTargetPlatform.name,
          'passcode': _pinController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_passcode', _pinController.text);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('is_device_linked', true);
        await prefs.setString('auth_token', data['token'] ?? '');
        
        // Save user data
        final userData = data['user'];
        if (userData != null) {
          final personData = userData['person'];
          if (personData != null) {
            final firstName = personData['person_first_name'] ?? '';
            final lastName = personData['person_last_name'] ?? '';
            await prefs.setString('user_name', '$firstName $lastName'.trim());
            await prefs.setString('user_email', personData['person_email'] ?? '');
          }
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardWrapper()),
          );
        }
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Failed to link device';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppTheme.darkError),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error'), backgroundColor: AppTheme.darkError),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _step == 1 ? 'Link Device' : 'Secure Your App',
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              _step == 1 
                ? 'Sign in with your staff credentials to authorize this device for attendance marking.'
                : 'Set a 4-digit security PIN for quick access to this device.',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white60, height: 1.5),
            ),
            const SizedBox(height: 48),
            
            if (_step == 1) ...[
              _buildTextField('Staff Email', _emailController, LucideIcons.mail, false),
              const SizedBox(height: 20),
              _buildTextField('Password', _passwordController, LucideIcons.lock, true),
              const SizedBox(height: 48),
              _buildButton('Next', () => setState(() => _step = 2)),
            ] else ...[
              _buildTextField('4-Digit Security PIN', _pinController, LucideIcons.key, false, isNumber: true, maxLength: 4),
              const SizedBox(height: 48),
              _buildButton(_isLoading ? 'Linking...' : 'Complete Setup', _isLoading ? null : _handleLink),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _step = 1),
                  child: Text('Back to Login', style: GoogleFonts.inter(color: Colors.white38)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isPassword, {bool isNumber = false, int? maxLength}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.emailAddress,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          counterText: "",
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: AppTheme.darkAccent, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.darkAccent,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
